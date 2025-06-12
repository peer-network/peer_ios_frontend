//
//  GroupCreationView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 09/06/25.
//

import SwiftUI
import Models
import DesignSystem

struct GroupCreationView: View {
    @ObservedObject var vm: GroupCreationViewModel
    
    var body: some View {
        ZStack {
            // Show either GroupCreationView or FriendSelectionView
            if vm.showFriendSelection {
                FriendSelectionView(
                    viewModel: vm.friendSelectionViewModel,
                    isGroupChat: true,
                    onDone: { selectedUsers in
                        vm.handleSelectedUsers(selectedUsers)
                        vm.showFriendSelection = false
                    },
                    onCreateGroupChat: vm.onCreateChat
                )
                .transition(.move(edge: .trailing)) // Slide in animation
            } else {
                GroupCreationContentView(vm: vm)
                    .transition(.move(edge: .leading)) // Slide out animation
            }
        }
        .animation(.default, value: vm.showFriendSelection)
    }
}

// Extracted the main content to a separate view for clarity
struct GroupCreationContentView: View {
    @ObservedObject var vm: GroupCreationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Create Group Chat")
                .font(.headline)
                .padding()
            
            Divider()
            
            // Group Name Field
            TextField("Group Name", text: $vm.groupName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Members List
            List {
                ForEach(vm.members, id: \.id) { user in
                    memberRow(for: user)
                        .contentShape(Rectangle())
                        .onTapGesture { vm.remove(user) }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            Divider()
            
            // Inline error
            if let err = vm.inlineError {
                Text(err)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            // Bottom buttons
            // Bottom buttons
            HStack(spacing: 16) {
                // Add People Button
                Button(action: {
                    withAnimation {
                        vm.prepareForFriendSelection()
                    }
                }) {
                    HStack {
                        Text("Add people")
                        Image(systemName: "plus")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .cornerRadius(24)
                }

                // Create Chat Button
                Button(action: {
                    vm.createChat()
                }) {
                    HStack {
                        Text("Create Chat")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(24)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)

        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
        .toast(isShowing: $vm.showSuccessToast, message: "Group created successfully")
    }
    
    private func memberRow(for user: RowUser) -> some View {
        HStack(spacing: 12) {
            ProfileAvatarView(
                url: user.imageURL,
                name: user.username,
                config: .rowUser,
                ignoreCache: false
            )
            
            Text(user.username)
                .fontWeight(.regular)
            
            Spacer()
            
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}
