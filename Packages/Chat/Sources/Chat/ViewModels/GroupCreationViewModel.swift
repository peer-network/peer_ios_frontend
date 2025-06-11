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

    
    // MARK: - Input
    @Published var groupName: String = ""
    @Published var members: [RowUser]
    
    // MARK: - Output
    @Published var isSubmitting = false
    @Published var inlineError: String?
    
    var onMembersUpdated: (([RowUser]) -> Void)?
    var onCreateSuccess: (() -> Void)? // Add this callback
    
    // MARK: - Callbacks
    let onAddAccounts: () -> Void
    
    init(
        initialMembers: [RowUser],
        onAddAccounts: @escaping () -> Void,
        onCreateSuccess: (() -> Void)? = nil,
        onCreateChat: @escaping (String, [String]) async -> Result<String, APIError>
        
    ) {
        self.onCreateChat = onCreateChat
        self.members = initialMembers
        self.onAddAccounts = onAddAccounts
        self.onCreateSuccess = onCreateSuccess
    }
    
    // MARK: - Actions
    func remove(_ user: RowUser) {
        members.removeAll { $0.id == user.id }
        onMembersUpdated?(members)
    }
    
    func createChat() {
        guard validateInputs() else { return }
        
        isSubmitting = true
        Task {
            let memberIds = members.map(\.id)
            let result = await onCreateChat(groupName, memberIds)
            print("onCreateChat", [groupName, memberIds,result])
           // let result = await coordinator.createGroupChat(name: groupName, memberIds: memberIds)
            
            await MainActor.run {
                isSubmitting = false
                switch result {
                case .success:
                    onCreateSuccess?()
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
