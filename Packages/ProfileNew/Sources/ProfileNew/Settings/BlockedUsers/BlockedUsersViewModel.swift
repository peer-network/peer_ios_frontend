//
//  BlockedUsersViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 18.06.25.
//

import Models
import Combine

@MainActor
final class BlockedUsersViewModel: ObservableObject {
    unowned var apiService: APIService!

    enum PageState {
        case loading
        case display
        case error(error: APIError)
    }

    @Published public private(set) var state: PageState = .loading
    @Published public private(set) var blockedUsers: [RowUser] = []
    private var fetchBlockedUsersTask: Task<Void, Never>?
    private var currentOffsetBlockedUsers: Int = 0
    @Published public private(set) var hasMoreBlockedUsers: Bool = true

    public func getMyBlockedUsers(reset: Bool) {
        if let existingTask = fetchBlockedUsersTask, !existingTask.isCancelled {
            if reset {
                // Cancel and start a fresh fetch for reset scenarios
                existingTask.cancel()
            } else {
                // Do not run a new task if there is already a task running
                return
            }
        }

        if reset {
            if blockedUsers.isEmpty {
                state = .loading
            }

            currentOffsetBlockedUsers = 0
            hasMoreBlockedUsers = true
        }

        fetchBlockedUsersTask = Task {
            do {
                let result = await apiService.fetchUsersWithHiddenContent(after: currentOffsetBlockedUsers)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedUsers):
                        if reset {
                            blockedUsers.removeAll()
                        }

                        blockedUsers.append(contentsOf: fetchedUsers)

                        if fetchedUsers.count != 20 {
                            hasMoreBlockedUsers = false
                        } else {
                            currentOffsetBlockedUsers += 20
                        }
                        state = .display
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
            } catch {
                state = .error(error: error as! APIError)
                blockedUsers = []
            }

            fetchBlockedUsersTask = nil
        }
    }

    public func removeBlockedUser(with id: String) {
        blockedUsers.removeAll { $0.id == id }
        currentOffsetBlockedUsers -= 1
    }
}
