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
    private var currentOffset: Int = 0
    private var hasMorePosts: Bool = true

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
            currentOffset = 0
            hasMorePosts = true
            listings.removeAll()
            Task { await cache.resetAll() }
        }

        guard hasMorePosts else {
            state = .ready(hasMore: false)
            return
        }

        fetchTask = Task {
            // if network failed earlier, allow retry on new fetch
            await cache.resetForRefresh()

            let maxEmptyPagesToSkip = 3
            var emptyPagesSkipped = 0
            var appendedAny = false

            while !Task.isCancelled, hasMorePosts {
                let page = await fetchPostsPage(apiService: apiService)
                switch page {
                case .failure(let err):
                    state = .error(err.userFriendlyDescription)
                    fetchTask = nil
                    return

                case .success(let fetchedPosts):
                    if fetchedPosts.isEmpty {
                        hasMorePosts = false
                        state = .ready(hasMore: false)
                        fetchTask = nil
                        return
                    }

                    // Firestore hydration (only unresolved)
                    let newListings = await hydrateAndBuildListings(from: fetchedPosts)

                    if !newListings.isEmpty {
                        listings.append(contentsOf: newListings) // single publish
                        appendedAny = true
                    } else {
                        emptyPagesSkipped += 1
                    }

                    // pagination end check
                    if fetchedPosts.count != 10 {
                        hasMorePosts = false
                    } else {
                        currentOffset += 10
                    }

                    // stop conditions for this fetch call
                    if appendedAny || emptyPagesSkipped >= maxEmptyPagesToSkip || !hasMorePosts {
                        state = .ready(hasMore: hasMorePosts)
                        fetchTask = nil
                        return
                    }

                    // else: this page produced 0 listings (all missing/failed) → loop and fetch next page
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

    private func fetchPostsPage(apiService: APIService) async -> Result<[Post], APIError> {
        await apiService.fetchPosts(
            with: .regular,    // your shop posts type (keep as-is if that’s correct)
            sort: .newest,
            showHiddenContent: true,
            filter: .all,
            in: .allTime,
            after: currentOffset,
            for: shopUserId,
            amount: 10
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
