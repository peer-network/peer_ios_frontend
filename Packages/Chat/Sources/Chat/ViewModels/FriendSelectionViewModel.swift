//
//  FriendSelectionViewModel.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import Models
import ProfileNew

@MainActor
final class FriendSelectionViewModel: ObservableObject {
    @Published var state: RelationsSheetState = .loading
    @Published var selectedUsers: [RowUser] = []

    private let relationsViewModel: RelationsViewModel
    private let allowsMultipleSelection: Bool

    init(userId: String, apiService: APIService, allowsMultipleSelection: Bool) {
        self.relationsViewModel = RelationsViewModel(userId: userId, apiService: apiService)
        self.allowsMultipleSelection = allowsMultipleSelection
        bindRelations()
        fetchFriends()
    }

    private func bindRelations() {
        Task {
            for await newState in relationsViewModel.$state.values {
                self.state = newState
                if case let .display(users, _) = newState {
                             print("Fetched friends: \(users.map { $0.username })")
                         }
            }
        }
    }

    func fetchFriends() {
        relationsViewModel.fetchFriends(reset: true)
    }
    func updateSelectedUsers(_ users: [RowUser]) {
            selectedUsers = users
        }
    
    func toggleSelection(for user: RowUser) {
            if let idx = selectedUsers.firstIndex(where: { $0.id == user.id }) {
                selectedUsers.remove(at: idx)
            } else {
                if allowsMultipleSelection {
                    selectedUsers.append(user)
                } else {
                    selectedUsers = [user]
                }
            }
        }
    }

