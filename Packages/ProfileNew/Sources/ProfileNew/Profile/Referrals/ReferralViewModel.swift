//
//  ReferralViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 26.05.25.
//

import Combine
import Models

@MainActor
final class ReferralViewModel: ObservableObject {
    unowned var apiService: APIService!

    enum PageState {
        case loading
        case display
        case error(error: APIError)
    }

    @Published public private(set) var refInfoState: PageState = .loading
    @Published public private(set) var myReferralInfo: ReferralInfo?

    @Published public private(set) var refUsersState: PageState = .loading
    @Published public private(set) var referredUsers: [RowUser] = []
    private var fetchReferredUsersTask: Task<Void, Never>?
    private var currentOffsetReferredUsers: Int = 0
    @Published public private(set) var hasMoreReferredUsers: Bool = true

    public func getMyReferralInfo() async {
        do {
            let result = await apiService.getMyReferralInfo()

            switch result {
            case .success(let referralInfo):
                myReferralInfo = referralInfo
                    refInfoState = .display
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            refInfoState = .error(error: error as! APIError)
        }
    }

    public func getMyReferredUsers(reset: Bool) {
        if let existingTask = fetchReferredUsersTask, !existingTask.isCancelled {
            if reset {
                // Cancel and start a fresh fetch for reset scenarios
                existingTask.cancel()
            } else {
                // Do not run a new task if there is already a task running
                return
            }
        }

        if reset {
            if referredUsers.isEmpty {
                refUsersState = .loading
            }
            
            currentOffsetReferredUsers = 0
            hasMoreReferredUsers = true
        }

        fetchReferredUsersTask = Task {
            do {
                let result = await apiService.getMyReferredUsers(after: currentOffsetReferredUsers)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedUsers):
                        if reset {
                            referredUsers.removeAll()
                        }
                        
                        referredUsers.append(contentsOf: fetchedUsers)

                        if fetchedUsers.count != 20 {
                            hasMoreReferredUsers = false
                        } else {
                            currentOffsetReferredUsers += 20
                        }
                        refUsersState = .display
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
            } catch {
                refUsersState = .error(error: error as! APIError)
                referredUsers = []
            }

            fetchReferredUsersTask = nil
        }
    }
}
