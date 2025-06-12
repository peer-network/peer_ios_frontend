//
//  FriendSelectionView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

//
//  FriendSelectionView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import Models
import Environment
import DesignSystem

struct FriendSelectionView: View {
    @ObservedObject var viewModel: FriendSelectionViewModel
    @State private var groupCreationViewModel: GroupCreationViewModel?
    let onCreateGroupChat: (String, [String]) async -> Result<String, APIError>
    
    let isGroupChat: Bool
    var onDone: ([RowUser]) -> Void

    // UI State
    @State private var inlineError: String?
    @State private var isShowingGroupCreation = false
    
    init(
            viewModel: FriendSelectionViewModel,
            isGroupChat: Bool,
            onDone: @escaping ([RowUser]) -> Void,
            onCreateGroupChat: @escaping (String, [String]) async -> Result<String, APIError> // Add this
        ) {
            self.viewModel = viewModel
            self.isGroupChat = isGroupChat
            self.onDone = onDone
            self.onCreateGroupChat = onCreateGroupChat // Add this
        }
        
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(isGroupChat ? "Select Group Members" : "Select Friend")
                .font(.headline)
                .padding()
            
            Divider()
            
            // List / Progress / Net-error
            switch viewModel.state {
            case .loading:
                ProgressView("Loading friends…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .display(let users, _):
                List(users, id: \.id) { user in
                    friendRow(for: user)
                        .onTapGesture {
                            handleSelection(for: user)
                        }
                }
                .listStyle(.plain)
                
            case .error(let err):
                Text(err.localizedDescription)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Divider()
            
            // Inline validation error
            if let msg = inlineError {
                Text(msg)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            // Bottom bar
            if isGroupChat {
                groupChatBottomBar
            }
//            else {
//                privateChatBottomBar
//            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
//        .navigationDestination(isPresented: $isShowingGroupCreation) {
//            if let vm = groupCreationViewModel {
//                GroupCreationView(vm: vm)
//            }
//        }
    }
    
    // MARK: - Subviews
    
    private func friendRow(for user: RowUser) -> some View {
        HStack(spacing: 12) {
            ProfileAvatarView(
                url: user.imageURL,
                name: user.username,
                config: .rowUser,
                ignoreCache: false
            )
            
            Text(user.username)
                .fontWeight(isSelected(user) ? .bold : .regular)
            
            Spacer()
            
            if isSelected(user) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
        .contentShape(Rectangle())
        .background(isSelected(user) ? Color.accentColor.opacity(0.1) : Color.clear)
    }
    
    private var groupChatBottomBar: some View {
        HStack {
            Text("\(viewModel.selectedUsers.count) account" +
                 (viewModel.selectedUsers.count == 1 ? "" : "s") +
                 " selected")
            Spacer()
            Button("Next") { validateAndFinish() }
                .disabled(viewModel.selectedUsers.isEmpty)
        }
        .padding()
    }
    
//    private var privateChatBottomBar: some View {
//        Button("Start Chat") {
//            validateAndFinish()
//        }
//        .disabled(viewModel.selectedUsers.isEmpty)
//        .padding()
//    }
    
    // MARK: - Selection Handling
    
    private func isSelected(_ user: RowUser) -> Bool {
        viewModel.selectedUsers.contains(where: { $0.id == user.id })
    }
    
    private func handleSelection(for user: RowUser) {
        inlineError = nil
        viewModel.toggleSelection(for: user)
        
        // For private chat, immediately proceed if a user is selected
        if !isGroupChat && viewModel.selectedUsers.count == 1 {
            validateAndFinish()
        }
    }
    
    private func validateAndFinish() {
        let count = viewModel.selectedUsers.count
        let isValid = isGroupChat ? count >= 2 : count == 1

        guard isValid else {
            inlineError = isGroupChat ?
                "Pick at least two friends for a group chat." :
                "Pick exactly one friend for a private chat."
            return
        }

        inlineError = nil
        
        if isGroupChat {
            // Proceed to group creation
//            groupCreationViewModel = GroupCreationViewModel(
//                initialMembers: viewModel.selectedUsers,
//                onAddAccounts: { isShowingGroupCreation = false },
//                onCreateChat: onCreateGroupChat
//            )
//            
//            groupCreationViewModel?.onMembersUpdated = { updatedMembers in
//                viewModel.selectedUsers = updatedMembers
//            }
//            
//            isShowingGroupCreation = true
            onDone(viewModel.selectedUsers)
        } else {
            // For private chat, call the completion handler with selected user
            onDone(viewModel.selectedUsers)
        }
    }
}
