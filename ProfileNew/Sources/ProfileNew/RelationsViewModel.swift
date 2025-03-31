//
//  RelationsViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import Models
import Networking
import GQLOperationsUser

enum RelationsSheetState {
    public enum PagingState {
        case hasMore, none
    }

    case loading
    case display(hasMore: RelationsSheetState.PagingState)
    case error(error: Error)
}

@MainActor
final class RelationsViewModel: ObservableObject {
    @Published private(set) var state = RelationsSheetState.loading

    @Published private(set) var followers: [RowUser] = []
    @Published private(set) var following: [RowUser] = []
    @Published private(set) var friends: [RowUser] = []

    let userId: String

    private var fetchTask: Task<Void, Never>?

    private var currentOffset: Int = 0
    private var hasMoreUsers: Bool = true

    init(userId: String) {
        self.userId = userId
        Task {
            await fetchUsers()
        }
    }

    func fetchUsers(reset: Bool = false) async {
        if let existingTask = fetchTask, !existingTask.isCancelled {
            return
        }

        fetchTask = Task {
            do {
//                let result = try await GQLClient.shared.fetch(query: GetFollowRelationsQuery(userid: GraphQLNullable(stringLiteral: userId), offset: GraphQLNullable<Int>(integerLiteral: currentOffset), limit: 20), cachePolicy: .fetchIgnoringCacheCompletely)
//
//                guard
//                    let followers = result.followrelations.affectedRows?.followers,
//                    let following = result.followrelations.affectedRows?.following,
//                    let friends = result.followrelations.affectedRows?.friends
//                else {
//                    throw GQLError.missingData
//                }
//
//                try Task.checkCancellation()
//
//                let fetchedFollowers = followers.compactMap { value in
//                    RowUser(gqlUser: value)
//                }
//                let fetchedFollowing = following.compactMap { value in
//                    RowUser(gqlUser: value)
//                }
//                let fetchedFriends = friends.compactMap { value in
//                    RowUser(gqlUser: value)
//                }
//
//                self.followers = fetchedFollowers
//                self.following = fetchedFollowing
//                self.friends = fetchedFriends

//                self.followers.append(contentsOf: fetchedFollowers)
//                self.following.append(contentsOf: fetchedFollowing)
//                self.friends.append(contentsOf: fetchedFriends)

//                if fetchedUsers.count != 20 {
                    hasMoreUsers = false
                    state = .display(hasMore: .none)
//                } else {
//                    currentOffset += 20
//                    state = .display(users: users, hasMore: .hasMore)
//                }

            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                print(error)
                print(error.localizedDescription)
                state = .error(error: error)
            }

            // Reset fetchTask to nil when done
            fetchTask = nil
        }
    }
}
