//
//  VideoFeedViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 27.07.25.
//

import Combine
import FeedList
import Models

@MainActor
final class VideoFeedViewModel: ObservableObject, PostsFetcher {
    unowned var apiService: APIService!

    private let userId: String

    @Published private(set) var state = PostsState.loading

    private var fetchTask: Task<Void, Never>?
    private var currentOffset: Int = 0
    private var hasMorePosts: Bool = true
    private var posts: [Post] = []

    private var currentOffsetAds: Int = 0
    private var hasMoreAds: Bool = true

    init(userId: String) {
        self.userId = userId
    }

    func fetchPosts(reset: Bool) {
        if let existingTask = fetchTask, !existingTask.isCancelled {
            if reset {
                // Cancel and start a fresh fetch for reset scenarios
                existingTask.cancel()
            } else {
                // Do not run a new task if there is already a task running
                return
            }
        }

        if reset {
            if posts.isEmpty {
                state = .loading
            }

            currentOffset = 0
            hasMorePosts = true

            currentOffsetAds = 0
            hasMoreAds = true
        }

        fetchTask = Task {
            do {
                if hasMoreAds {
                    let advertisements = try await fetchAdvertisements()

                    if reset {
                        posts.removeAll()
                    }

                    posts.append(contentsOf: advertisements)
                    state = .display(posts: posts, hasMore: .hasMore)

                    if hasMoreAds {
                        fetchTask = nil
                        return
                    }
                }
                
                let result = await apiService.fetchPosts(
                    with: .video,
                    sort: .newest,
                    showHiddenContent: true,
                    filter: .all,
                    in: .allTime,
                    after: currentOffset,
                    for: userId,
                    amount: Constants.postsFetchLimit
                )

                try Task.checkCancellation()

                switch result {
                case .success(let fetchedPosts):
//                    if reset {
//                        posts.removeAll()
//                    }

                    posts.append(contentsOf: fetchedPosts)

                    if fetchedPosts.count != Constants.postsFetchLimit {
                        hasMorePosts = false
                        state = .display(posts: posts, hasMore: .none)
                    } else {
                        currentOffset += Constants.postsFetchLimit
                        state = .display(posts: posts, hasMore: .hasMore)
                    }
                case .failure(let apiError):
                    throw apiError
                }
            } catch is CancellationError {
//                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                state = .error(error: error)
                posts = []
            }

            // Reset fetchTask to nil when done
            fetchTask = nil
        }
    }

    private func fetchAdvertisements() async throws -> [Post] {
        let result = await apiService.getListOfAds(userID: userId, with: .video, after: currentOffsetAds, amount: Constants.postsFetchLimit)

        try Task.checkCancellation()

        switch result {
            case .success(let fetchedAds):
                if fetchedAds.count != Constants.postsFetchLimit {
                    hasMoreAds = false
                } else {
                    currentOffsetAds += Constants.postsFetchLimit
                }
                return fetchedAds
            case .failure(let apiError):
                throw apiError
        }
    }
}
