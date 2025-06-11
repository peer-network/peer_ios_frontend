//
//  RelationsViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import Models

@MainActor
public protocol RelationsFetcher: ObservableObject {
    var state: RelationsSheetState { get }
    func fetchFollowers(reset: Bool)
    func fetchFollowings(reset: Bool)
    func fetchFriends(reset: Bool)
}

public enum RelationsSheetState {
    public enum PagingState {
        case hasMore, none
    }

    case loading
    case display(users: [RowUser], hasMore: RelationsSheetState.PagingState)
    case error(error: Error)
}

@MainActor
public final class RelationsViewModel: ObservableObject, RelationsFetcher {

    @Published private(set) public var state = RelationsSheetState.loading

    @Published private(set) var followers: [RowUser] = []
    @Published private(set) var following: [RowUser] = []
    @Published private(set) var friends: [RowUser] = []

    let userId: String
    private let apiService: APIService

    private var fetchFollowersTask: Task<Void, Never>?
    private var fetchFollowingsTask: Task<Void, Never>?
    private var fetchFriendsTask: Task<Void, Never>?

    private var currentOffsetFollowers: Int = 0
    private var currentOffsetFollowings: Int = 0
    private var currentOffsetFriends: Int = 0
    private var hasMoreFollowers: Bool = true
    private var hasMoreFollowings: Bool = true
    private var hasMoreFriends: Bool = true

    public init(userId: String, apiService: APIService) {
        self.userId = userId
        self.apiService = apiService
    }

    public func fetchFollowers(reset: Bool) {
        if let existingTask = fetchFollowersTask, !existingTask.isCancelled {
            return
        }

        if reset {
            if followers.isEmpty {
                state = .loading
            }

            currentOffsetFollowers = 0
            hasMoreFollowers = true
        }

        fetchFollowersTask = Task {
            do {
                let result = await apiService.fetchUserFollowers(for: userId, after: currentOffsetFollowers)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedFollowers):
                        if reset {
                            followers.removeAll()
                        }

                        followers.append(contentsOf: fetchedFollowers)

                        if fetchedFollowers.count != 20 {
                            hasMoreFollowers = false
                            state = .display(users: followers, hasMore: .none)
                        } else {
                            currentOffsetFollowers += 20
                            state = .display(users: followers, hasMore: .hasMore)
                        }
                    case .failure(let apiError):
                        throw apiError
                }

                fetchFollowersTask = nil
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                state = .error(error: error)
            }
        }
    }

    public func fetchFollowings(reset: Bool) {
        if let existingTask = fetchFollowingsTask, !existingTask.isCancelled {
            return
        }

        if reset {
            if following.isEmpty {
                state = .loading
            }

            currentOffsetFollowings = 0
            hasMoreFollowings = true
        }

        fetchFollowingsTask = Task {
            do {
                let result = await apiService.fetchUserFollowings(for: userId, after: currentOffsetFollowings)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedFollowings):
                        if reset {
                            following.removeAll()
                        }

                        following.append(contentsOf: fetchedFollowings)

                        if fetchedFollowings.count != 20 {
                            hasMoreFollowings = false
                            state = .display(users: following, hasMore: .none)
                        } else {
                            currentOffsetFollowings += 20
                            state = .display(users: following, hasMore: .hasMore)
                        }
                    case .failure(let apiError):
                        throw apiError
                }

                fetchFollowingsTask = nil
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                print(error)
                print(error.localizedDescription)
                state = .error(error: error)
            }
        }
    }

    public func fetchFriends(reset: Bool) {
        if let existingTask = fetchFriendsTask, !existingTask.isCancelled {
            return
        }

        if reset {
            if friends.isEmpty {
                state = .loading
            }

            currentOffsetFriends = 0
            hasMoreFriends = true
        }

        fetchFriendsTask = Task {
            do {
                let result = await apiService.fetchUserFriends(after: currentOffsetFriends)

                try Task.checkCancellation()
                print("frdresult", result)
                switch result {
                    case .success(let fetchedFriends):
                        if reset {
                            friends.removeAll()
                        }

                        friends.append(contentsOf: fetchedFriends)
                    print("fetchedFriends", fetchedFriends)
                        if fetchedFriends.count != 20 {
                            hasMoreFriends = false
                            state = .display(users: friends, hasMore: .none)
                        } else {
                            currentOffsetFriends += 20
                            state = .display(users: friends, hasMore: .hasMore)
                        }
                    case .failure(let apiError):
                        throw apiError
                }

                fetchFriendsTask = nil
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                print(error)
                print(error.localizedDescription)
                state = .error(error: error)
            }
        }
    }
}
