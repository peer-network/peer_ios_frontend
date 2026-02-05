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

    @Published private(set) var trendindPosts: [Post] = []

    /// Used by UI for pagination in tag/title/user searches
    @Published private(set) var hasMore: Bool = true

    /// Used by UI for pagination in trending
    @Published private(set) var hasMoreTrendind: Bool = true

    // MARK: - Paging constants

    private enum Page {
        static let ads = 20
        static let searchPosts = 20
        static let users = 20
        static let trending = 18
    }

    // MARK: - Internal queries

    private enum PostsQuery: Equatable {
        case tag(String)
        case title(String)

        var tag: String? {
            if case .tag(let v) = self { return v }
            return nil
        }

        var title: String? {
            if case .title(let v) = self { return v }
            return nil
        }
    }

    // MARK: - Tasks (prevents overlap + enables cancel)

    private var postsTask: Task<Void, Never>?
    private var usersTask: Task<Void, Never>?
    private var trendingTask: Task<Void, Never>?
    private var tagsTask: Task<Void, Never>?

    // MARK: - Search posts paging (ADS FIRST, then regular posts)

    private var activePostsQuery: PostsQuery?

    private var adsOffset: Int = 0
    private var hasMoreAds: Bool = true

    private var postsOffset: Int = 0
    private var hasMorePosts: Bool = true

    // MARK: - Users paging

    private var activeUsersQuery: String?
    private var usersOffset: Int = 0
    private var hasMoreUsers: Bool = true

    // MARK: - Trending paging

    private var trendingOffset: Int = 0

    // MARK: - Public API

    func cleanup() {
        // Cancel in-flight work so it won't race and update UI after reset
        cancelAll()

        tags = []
        posts = []
        users = []

        // reset search paging
        activePostsQuery = nil
        adsOffset = 0
        hasMoreAds = true
        postsOffset = 0
        hasMorePosts = true

        // reset users paging
        activeUsersQuery = nil
        usersOffset = 0
        hasMoreUsers = true

        hasMore = true
        state2 = .display
    }

    func fetchTrendingPosts(reset: Bool) async {
        // prevent overlap
        if let t = trendingTask, !t.isCancelled {
            if reset { t.cancel() } else { return }
        }

        if reset {
            trendindPosts.removeAll()
            trendingOffset = 0
            hasMoreTrendind = true
        }

        if trendindPosts.isEmpty { state2 = .loading }

        let task = Task { [weak self] in
            guard let self else { return }
            defer { self.trendingTask = nil }

            do {
                guard self.hasMoreTrendind else {
                    self.state2 = .display
                    return
                }

                let result = await self.apiService.fetchPosts(
                    with: .imageAndVideo,
                    sort: .trending,
                    showHiddenContent: false,
                    filter: .all,
                    in: .week,
                    after: self.trendingOffset,
                    for: nil,
                    amount: Page.trending
                )

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedPosts):
                        self.trendindPosts.append(contentsOf: fetchedPosts)

                        if fetchedPosts.count != Page.trending {
                            self.hasMoreTrendind = false
                        } else {
                            self.trendingOffset += Page.trending
                            self.hasMoreTrendind = true
                        }

                        self.state2 = .display

                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
                // ignore
            } catch {
                self.state2 = .error(error)
            }
        }

        trendingTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    func fetchTags(tag: String) async {
        tagsTask?.cancel()

        let task = Task { [weak self] in
            guard let self else { return }
            defer { self.tagsTask = nil }

            do {
                let result = await self.apiService.fetchTags(with: tag)
                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedTags):
                        self.tags = fetchedTags
                    case .failure:
                        break
                }
            } catch is CancellationError {
                // ignore
            } catch {
                // ignore (suggestions should not break the whole screen)
            }
        }

        tagsTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    func fetchPosts(reset: Bool, tag: String) async {
        await fetchPosts(reset: reset, query: .tag(tag))
    }

    func fetchPosts(reset: Bool, title: String) async {
        await fetchPosts(reset: reset, query: .title(title))
    }

    func fetchUsers(reset: Bool, username: String) async {
        let queryChanged = (activeUsersQuery != username)
        let shouldReset = reset || queryChanged

        if let t = usersTask, !t.isCancelled {
            if shouldReset { t.cancel() } else { return }
        }

        if shouldReset {
            activeUsersQuery = username
            users.removeAll()
            usersOffset = 0
            hasMoreUsers = true
            hasMore = true
        }

        if users.isEmpty { state2 = .loading }

        let task = Task { [weak self] in
            guard let self else { return }
            defer { self.usersTask = nil }

            do {
                guard self.hasMoreUsers else {
                    self.hasMore = false
                    self.state2 = .display
                    return
                }

                let result = await self.apiService.fetchUsers(by: username, after: self.usersOffset)
                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedUsers):
                        self.users.append(contentsOf: fetchedUsers)

                        if fetchedUsers.count != Page.users {
                            self.hasMoreUsers = false
                        } else {
                            self.usersOffset += Page.users
                            self.hasMoreUsers = true
                        }

                        self.hasMore = self.hasMoreUsers
                        self.state2 = .display

                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
                // ignore
            } catch {
                self.state2 = .error(error)
            }
        }

        usersTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    // MARK: - Private helpers

    private func cancelAll() {
        postsTask?.cancel(); postsTask = nil
        usersTask?.cancel(); usersTask = nil
        trendingTask?.cancel(); trendingTask = nil
        tagsTask?.cancel(); tagsTask = nil
    }

    private func fetchPosts(reset: Bool, query: PostsQuery) async {
        let queryChanged = (activePostsQuery != query)
        let shouldReset = reset || queryChanged

        if let t = postsTask, !t.isCancelled {
            if shouldReset { t.cancel() } else { return }
        }

        if shouldReset {
            activePostsQuery = query

            posts.removeAll()

            // reset ADS paging
            adsOffset = 0
            hasMoreAds = true

            // reset REGULAR posts paging
            postsOffset = 0
            hasMorePosts = true

            hasMore = true
        }

        if posts.isEmpty { state2 = .loading }

        let task = Task { [weak self] in
            guard let self else { return }
            defer { self.postsTask = nil }

            do {
                // 1) ADS FIRST (filtered by title/tag)
                if self.hasMoreAds {
                    let adsResult = await self.apiService.getListOfAds(
                        userID: nil,
                        title: query.title,
                        tag: query.tag,
                        with: .regular,
                        after: self.adsOffset,
                        amount: Page.ads
                    )

                    try Task.checkCancellation()

                    switch adsResult {
                        case .success(let fetchedAds):
                            self.posts.append(contentsOf: fetchedAds)

                            if fetchedAds.count != Page.ads {
                                self.hasMoreAds = false
                            } else {
                                self.adsOffset += Page.ads
                                self.hasMoreAds = true
                            }

                            self.hasMore = self.hasMoreAds || self.hasMorePosts
                            self.state2 = .display

                            // If there are still ads, stop here (ads must fully come first)
                            if self.hasMoreAds { return }

                        case .failure(let apiError):
                            throw apiError
                    }
                }

                // 2) THEN regular posts (tag/title)
                guard self.hasMorePosts else {
                    self.hasMore = false
                    self.state2 = .display
                    return
                }

                switch query {
                    case .tag(let tag):
                        let result = await self.apiService.fetchPostsByTag(tag, after: self.postsOffset)
                        try Task.checkCancellation()

                        switch result {
                            case .success(let fetchedPosts):
                                self.posts.append(contentsOf: fetchedPosts)

                                if fetchedPosts.count != Page.searchPosts {
                                    self.hasMorePosts = false
                                } else {
                                    self.postsOffset += Page.searchPosts
                                    self.hasMorePosts = true
                                }

                                self.hasMore = self.hasMoreAds || self.hasMorePosts
                                self.state2 = .display

                            case .failure(let apiError):
                                throw apiError
                        }

                    case .title(let title):
                        let result = await self.apiService.fetchPostsByTitle(title, after: self.postsOffset)
                        try Task.checkCancellation()

                        switch result {
                            case .success(let fetchedPosts):
                                self.posts.append(contentsOf: fetchedPosts)

                                if fetchedPosts.count != Page.searchPosts {
                                    self.hasMorePosts = false
                                } else {
                                    self.postsOffset += Page.searchPosts
                                    self.hasMorePosts = true
                                }

                                self.hasMore = self.hasMoreAds || self.hasMorePosts
                                self.state2 = .display

                            case .failure(let apiError):
                                throw apiError
                        }
                }

            } catch is CancellationError {
                // ignore
            } catch {
                self.state2 = .error(error)
            }
        }

        postsTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }
}
