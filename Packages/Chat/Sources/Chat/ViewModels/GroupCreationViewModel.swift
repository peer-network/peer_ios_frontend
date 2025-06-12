//
//  GroupCreationViewModel.swift
//  Chat
//
//  Created by Siva kumar Aketi on 09/06/25.
//

import SwiftUI
import Models

@MainActor
final class GroupCreationViewModel: ObservableObject {
    
    let onCreateChat: (String, [String]) async -> Result<String, APIError>
    
    @Published var showFriendSelection = false
    let friendSelectionViewModel: FriendSelectionViewModel
    
    var isValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty && members.count >= 2
    }
    
    @Published var showSuccessToast = false

    // MARK: - Input
    @Published var groupName: String = ""
    @Published var members: [RowUser]
    
    // MARK: - Output
    @Published var isSubmitting = false
    @Published var inlineError: String?
    
    var onMembersUpdated: (([RowUser]) -> Void)?
    var onCreateSuccess: (() -> Void)?
    
    // MARK: - Callbacks
    let onAddAccounts: () -> Void
    
    init(
        initialMembers: [RowUser],
        onAddAccounts: @escaping () -> Void,
        onCreateSuccess: (() -> Void)? = nil,
        friendSelectionViewModel: FriendSelectionViewModel,
        onCreateChat: @escaping (String, [String]) async -> Result<String, APIError>
        
    ) {
        self.onCreateChat = onCreateChat
        self.members = initialMembers
        self.friendSelectionViewModel = friendSelectionViewModel
        self.friendSelectionViewModel.selectedUsers = initialMembers
        self.onAddAccounts = onAddAccounts
        self.onCreateSuccess = onCreateSuccess
    }
    
    // MARK: - Actions
    func remove(_ user: RowUser) {
        members.removeAll { $0.id == user.id }
        onMembersUpdated?(members)
    }
    
    func handleSelectedUsers(_ users: [RowUser]) {
        members = users
        onMembersUpdated?(members)
    }
    
    func prepareForFriendSelection() {
        friendSelectionViewModel.selectedUsers = members
        showFriendSelection = true
    }
    
    func createChat() {
        guard validateInputs() else { return }
        
        isSubmitting = true
        
        Task {
            let memberIds = members.map(\.id)
            let result = await onCreateChat(groupName, memberIds)
            
            await MainActor.run {
                isSubmitting = false
                
                switch result {
                case .success:
                    // Show toast
                    showSuccessToast = true
                    
                    // Hide toast after 2 seconds and then call success callback to dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showSuccessToast = false
                        self.onCreateSuccess?()
                    }
                    
                case .failure(let error):
                    inlineError = error.userFriendlyMessage
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    private func validateInputs() -> Bool {
        inlineError = nil
        
        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            inlineError = "Please enter a group name"
            return false
        }
        
        guard members.count >= 2 else {
            inlineError = "Pick at least two accounts"
            return false
        }
        
        return true
    }
}

