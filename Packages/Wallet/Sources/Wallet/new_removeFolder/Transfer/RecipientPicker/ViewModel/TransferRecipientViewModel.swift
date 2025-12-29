//
//  TransferRecipientViewModel.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import Environment
import Models

@MainActor
final class TransferRecipientViewModel: ObservableObject {
    unowned var apiService: APIService!

    @Published private(set) var state: PaginatedContentState<[RowUser]> =
        .display(content: [], hasMore: .none)

    @Published private(set) var stateVersion: Int = 0

    private var users: [RowUser] = []
    private var fetchUsersTask: Task<Void, Never>?
    private var currentOffset: Int = 0

    private func setState(_ newState: PaginatedContentState<[RowUser]>) {
        state = newState
        stateVersion &+= 1
    }

    func fetchContent(username: String, reset: Bool) {
        fetchUsersTask?.cancel()

        if reset {
            setState(.loading(placeholder: RowUser.placeholders()))
            users.removeAll()
            currentOffset = 0
        }

        fetchUsersTask = Task {
            do {
                let result = await apiService.fetchUsers(by: username.lowercased(), after: currentOffset)
                try Task.checkCancellation()

                switch result {
                case .success(let fetchedUsers):
                    users.append(contentsOf: fetchedUsers)

                    if fetchedUsers.count != 20 {
                        setState(.display(content: users, hasMore: .none))
                    } else {
                        currentOffset += 20
                        setState(.display(content: users, hasMore: .hasMore))
                    }

                case .failure(let apiError):
                    throw apiError
                }

                fetchUsersTask = nil
            } catch is CancellationError {
                // ignore
            } catch {
                setState(.error(error: error))
            }
        }
    }

    func clearResults() {
        fetchUsersTask?.cancel()
        setState(.display(content: [], hasMore: .none))
    }
}
