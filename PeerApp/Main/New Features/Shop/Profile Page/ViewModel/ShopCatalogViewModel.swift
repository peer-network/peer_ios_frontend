//
//  ShopCatalogViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 06.01.26.
//

import SwiftUI
import Models
import Environment

@MainActor
final class ShopCatalogViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case ready(hasMore: Bool)
        case error(String)
    }

    var apiService: APIService?

    private let shopUserId: String
    private let repo: ShopItemRepository
    private let cache = ShopItemCache()

    private var fetchTask: Task<Void, Never>?

    // MARK: - Pagination

    private let pageSize: Int = 10

    // Ads (pinned) pagination
    private var currentOffsetAds: Int = 0
    private var hasMoreAds: Bool = true

    // Regular posts pagination
    private var currentOffsetPosts: Int = 0
    private var hasMorePosts: Bool = true

    // MARK: - Output

    @Published private(set) var state: State = .loading
    @Published private(set) var listings: [ShopListing] = []

    init(shopUserId: String, repo: ShopItemRepository) {
        self.shopUserId = shopUserId
        self.repo = repo
    }

    func refresh() {
        fetchNextPage(reset: true)
    }

    func fetchNextPage(reset: Bool) {
        guard let apiService else { return }

        if let t = fetchTask, !t.isCancelled {
            if reset { t.cancel() } else { return }
        }

        if reset {
            state = .loading

            currentOffsetAds = 0
            hasMoreAds = true

            currentOffsetPosts = 0
            hasMorePosts = true

            listings.removeAll()
        }

        // Nothing left to load at all
        guard hasMoreAds || hasMorePosts else {
            state = .ready(hasMore: false)
            return
        }

        fetchTask = Task {
            // If reset, fully reset cache before fetching anything
            if reset {
                await cache.resetAll()
            } else {
                // transient failures should be retriable on next fetch
                await cache.resetForRefresh()
            }

            let maxEmptyPagesToSkip = 3
            var emptyPagesSkipped = 0
            var appendedAny = false

            // For dedupe (ads might overlap with regular posts)
            var seenIDs = Set(listings.map(\.id))

            enum Stage { case ads, posts }

            while !Task.isCancelled, (hasMoreAds || hasMorePosts) {

                let stage: Stage = hasMoreAds ? .ads : .posts

                let pageResult: Result<[Post], APIError> = await {
                    switch stage {
                        case .ads:
                            return await fetchAdsPage(apiService: apiService)
                        case .posts:
                            return await fetchPostsPage(apiService: apiService)
                    }
                }()

                switch pageResult {
                    case .failure(let err):
                        state = .error(err.userFriendlyDescription)
                        fetchTask = nil
                        return

                    case .success(let fetchedPosts):
                        // If the backend returns nothing, this stream is finished.
                        if fetchedPosts.isEmpty {
                            switch stage {
                                case .ads:
                                    hasMoreAds = false
                                    // Continue the loop → start fetching regular posts in this same call
                                    continue
                                case .posts:
                                    hasMorePosts = false
                                    state = .ready(hasMore: false)
                                    fetchTask = nil
                                    return
                            }
                        }

                        // Firestore hydration (ads and regular posts use the same logic)
                        let newListingsAll = await hydrateAndBuildListings(from: fetchedPosts)

                        // Dedupe (in case ads are also returned in normal posts)
                        let newListings = newListingsAll.filter { seenIDs.insert($0.id).inserted }

                        if !newListings.isEmpty {
                            listings.append(contentsOf: newListings) // single publish
                            appendedAny = true
                        } else {
                            emptyPagesSkipped += 1
                        }

                        // Update pagination for the current stage
                        if fetchedPosts.count != pageSize {
                            switch stage {
                                case .ads:
                                    hasMoreAds = false
                                case .posts:
                                    hasMorePosts = false
                            }
                        } else {
                            switch stage {
                                case .ads:
                                    currentOffsetAds += pageSize
                                case .posts:
                                    currentOffsetPosts += pageSize
                            }
                        }

                        let hasMoreAnything = hasMoreAds || hasMorePosts

                        // Stop conditions (same spirit as your original implementation)
                        if !hasMoreAnything {
                            state = .ready(hasMore: false)
                            fetchTask = nil
                            return
                        }

                        if appendedAny {
                            // Important nuance:
                            // If we just finished ads (hasMoreAds == false), keep looping once
                            // so regular posts can start immediately right after ads.
                            if stage == .ads && !hasMoreAds {
                                appendedAny = false
                                emptyPagesSkipped = 0
                                continue
                            }

                            state = .ready(hasMore: hasMoreAnything)
                            fetchTask = nil
                            return
                        }

                        if emptyPagesSkipped >= maxEmptyPagesToSkip {
                            state = .ready(hasMore: hasMoreAnything)
                            fetchTask = nil
                            return
                        }

                        // else: page produced 0 listings (all missing/failed) → loop and fetch next page
                }
            }

            fetchTask = nil
        }
    }

    func loadMoreIfNeeded(currentListingID: String) {
        guard let last = listings.last?.id else { return }
        if currentListingID == last {
            fetchNextPage(reset: false)
        }
    }

    // MARK: - Internals

    private func fetchAdsPage(apiService: APIService) async -> Result<[Post], APIError> {
        // Same call pattern as NormalFeedViewModel, but scoped to this shop user.
        await apiService.getListOfAds(
            userID: shopUserId,
            with: .regular,
            after: currentOffsetAds,
            amount: pageSize
        )
    }

    private func fetchPostsPage(apiService: APIService) async -> Result<[Post], APIError> {
        await apiService.fetchPosts(
            with: .regular,
            sort: .newest,
            showHiddenContent: true,
            filter: .all,
            in: .allTime,
            after: currentOffsetPosts,
            for: shopUserId,
            amount: pageSize
        )
    }

    private func hydrateAndBuildListings(from posts: [Post]) async -> [ShopListing] {
        let ids = posts.map(\.id)

        // Get cache once (no per-post await)
        let cached = await cache.items(for: ids)

        // Fetch only unresolved
        let idsToFetch = await cache.unresolvedIDs(from: ids)
        var fetched: [String: ShopItem] = [:]

        if !idsToFetch.isEmpty {
            do {
                fetched = try await repo.fetchItems(postIDs: idsToFetch)
                await cache.mergeFetched(fetched, requestedIDs: idsToFetch)
            } catch {
                // transient failure: don't show these posts at all
                await cache.markFailed(idsToFetch)
            }
        }

        // Merge maps (local, sync)
        var byID = cached
        byID.merge(fetched) { _, new in new }

        // ONLY show posts with resolved shop item
        return posts.compactMap { post in
            guard let item = byID[post.id] else { return nil }
            return ShopListing(post: post, item: item)
        }
    }
}
