//
//  ExploreViewModel.swift
//  Explore
//
//  Created by Artem Vasin on 12.05.25.
//

import Combine
import Models

@MainActor
final class ExploreViewModel: ObservableObject {
    public unowned var apiService: (any APIService)!

    enum State {
        case loading
        case display
        case error(Error)
    }

    @Published private(set) var state2: State = .loading
    var isLoading: Bool {
        if case .loading = state2 { return true }
        return false
    }

    @Published private(set) var tags: [String] = []
    @Published private(set) var posts: [Post] = []
    @Published private(set) var users: [RowUser] = []

    private var currentOffset: Int = 0
    public private(set) var hasMore: Bool = true

    @Published private(set) var trendindPosts: [Post] = []
    private var currentOffsetTrendind: Int = 0
    public private(set) var hasMoreTrendind: Bool = true

    func cleanup() {
        tags = []
        posts = []
        users = []
        currentOffset = 0
        hasMore = true
        state2 = .display
    }

    func fetchTrendingPosts(reset: Bool) async {
        do {
            if reset {
                trendindPosts.removeAll()
                currentOffsetTrendind = 0
                hasMoreTrendind = true
            }

            if trendindPosts.isEmpty {
                state2 = .loading
            }

            let result = await apiService.fetchPosts(with: .imageAndVideo, sort: .trending, showHiddenContent: false, filter: .all, in: .week, after: currentOffsetTrendind, for: nil, amount: 18)

            try Task.checkCancellation()

            switch result {
                case .success(let fetchedPosts):
                    trendindPosts.append(contentsOf: fetchedPosts)

                    if fetchedPosts.count != 18 {
                        hasMoreTrendind = false
                    } else {
                        currentOffsetTrendind += 18
                        hasMoreTrendind = true
                    }
                    state2 = .display
                case .failure(let apiError):
                    throw apiError
            }
        } catch is CancellationError {
        } catch {
            state2 = .error(error)
        }
    }

    func fetchTags(tag: String) async {
        do {
            let result = await apiService.fetchTags(with: tag)

            try Task.checkCancellation()

            switch result {
                case .success(let fetchedTags):
                    tags = fetchedTags
                case .failure(let apiError):
                    throw apiError
            }
        } catch is CancellationError {

        } catch {
            
        }
    }

    func fetchPosts(reset: Bool, tag: String) async {
        do {
            if reset {
                posts.removeAll()
                currentOffset = 0
                hasMore = true
            }

            if posts.isEmpty {
                state2 = .loading
            }

            let result = await apiService.fetchPostsByTag(tag, after: currentOffset)

            try Task.checkCancellation()

            switch result {
                case .success(let fetchedPosts):
                    posts.append(contentsOf: fetchedPosts)

                    if fetchedPosts.count != 20 {
                        hasMore = false
                    } else {
                        currentOffset += 20
                        hasMore = true
                    }
                    state2 = .display
                case .failure(let apiError):
                    throw apiError
            }
        } catch is CancellationError {
        } catch {
            state2 = .error(error)
        }
    }

    func fetchPosts(reset: Bool, title: String) async {
        do {
            if reset {
                posts.removeAll()
                currentOffset = 0
                hasMore = true
            }

            if posts.isEmpty {
                state2 = .loading
            }

            let result = await apiService.fetchPostsByTitle(title, after: currentOffset)

            try Task.checkCancellation()

            switch result {
                case .success(let fetchedPosts):
                    posts.append(contentsOf: fetchedPosts)

                    if fetchedPosts.count != 20 {
                        hasMore = false
                    } else {
                        currentOffset += 20
                        hasMore = true
                    }
                    state2 = .display
                case .failure(let apiError):
                    throw apiError
            }
        } catch is CancellationError {
        } catch {
            state2 = .error(error)
        }
    }

    func fetchUsers(reset: Bool, username: String) async {
        do {
            if reset {
                users.removeAll()
                currentOffset = 0
                hasMore = true
            }

            if users.isEmpty {
                state2 = .loading
            }

            let result = await apiService.fetchUsers(by: username, after: currentOffset)

            try Task.checkCancellation()

            switch result {
                case .success(let fetchedUsers):
                    users.append(contentsOf: fetchedUsers)

                    if fetchedUsers.count != 20 {
                        hasMore = false
                    } else {
                        currentOffset += 20
                        hasMore = true
                    }
                    state2 = .display
                case .failure(let apiError):
                    throw apiError
            }
        } catch is CancellationError {
        } catch {
            state2 = .error(error)
        }
    }
}
