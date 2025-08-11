//
//  RecipientPickerViewModel.swift
//  Wallet
//
//  Created by Artem Vasin on 02.05.25.
//

import Environment
import Models
import Combine

@MainActor
final class RecipientPickerViewModel: ObservableObject {
    unowned var apiService: APIService!

    @Published private(set) var state: PaginatedContentState<[RowUser]> = .display(content: [], hasMore: .none)
    private var users: [RowUser] = []

    private var fetchUsersTask: Task<Void, Never>?
    private var currentOffset: Int = 0

    func fetchContent(username: String, reset: Bool) {
        if let existingTask = fetchUsersTask {
            existingTask.cancel()
        }

        if reset {
            state = .loading(placeholder: RowUser.placeholders())
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
                        state = .display(content: users, hasMore: .none)
                    } else {
                        currentOffset += 20
                        state = .display(content: users, hasMore: .hasMore)
                    }
                case .failure(let apiError):
                    throw apiError
                }

                fetchUsersTask = nil
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                print(error)
                print(error.localizedDescription)
                state = .error(error: error)
            }
        }
    }

    func clearResults() {
        fetchUsersTask?.cancel()
        state = .display(content: [], hasMore: .none)
    }
}
