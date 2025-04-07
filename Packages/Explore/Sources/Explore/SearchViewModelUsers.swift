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
    public unowned var apiService: (any APIService)!
    
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
                let result = await apiService.fetchUsers(by: username.lowercased(), after: currentOffset)
                
                try Task.checkCancellation()
                
                switch result {
                case .success(let fetchedUsers):
                    users.append(contentsOf: fetchedUsers)
                    
                    if fetchedUsers.count != 20 {
                        hasMoreUsers = false
                    } else {
                        currentOffset += 20
                        hasMoreUsers = true
                    }
                case .failure(let apiError):
                    throw apiError
                }
            } catch {
                
            }
            
            fetchTask = nil
        }
    }
}
