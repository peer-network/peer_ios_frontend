//
//  SearchViewModelUsers.swift
//  PeerApp
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import Models
import Networking
import GQLOperationsUser

@MainActor
final class SearchViewModelUsers: ObservableObject {
    private var fetchTask: Task<Void, Never>?

    @Published var users: [RowUser] = []

    private var currentOffset: Int = 0
    private var hasMoreUsers: Bool = true

    func fetchUsers(reset: Bool, username: String) async {
        if let existingTask = fetchTask, !existingTask.isCancelled {
            existingTask.cancel()
        }

        if reset {
            users = []
            hasMoreUsers = true
            currentOffset = 0
        }

        fetchTask = Task {
            do {
                let operation = SearchUserQuery(userid: nil, username: GraphQLNullable(stringLiteral: username.lowercased()), offset: GraphQLNullable<Int>(integerLiteral: currentOffset), limit: 20)

                let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

                guard let values = result.searchuser.affectedRows else {
                    throw GQLError.missingData
                }

                try Task.checkCancellation()

                let fetchedUsers = values.compactMap { value in
                    RowUser(gqlUser: value)
                }

                users.append(contentsOf: fetchedUsers)

                if fetchedUsers.count != 20 {
                    hasMoreUsers = false
                } else {
                    currentOffset += 20
                    hasMoreUsers = true
                }
            } catch {
                
            }

            fetchTask = nil
        }
    }
}
