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
            // Background color matching your design system
            Colors.textActive.ignoresSafeArea()
            
            // Main content switcher
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
                .transition(.move(edge: .trailing))
                .background(Colors.textActive)
            } else {
                GroupCreationContentView(vm: vm)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.default, value: vm.showFriendSelection)
        .toast(isShowing: $vm.showSuccessToast, message: "Group created successfully")
    }
}

struct GroupCreationContentView: View {
    @ObservedObject var vm: GroupCreationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Create Group Chat")
                .font(.customFont(weight: .bold, style: .body))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Group Name Field
            TextField("*Give a name to chat", text: $vm.groupName)
                .padding(.leading, 44)
                .padding(.vertical, 12)
                .font(.customFont(weight: .regular, style: .body))
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                )
                .overlay(
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 28, height: 28)
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                )
                .padding(.horizontal)
                .foregroundColor(.white)
                .accentColor(.white)
            
            // Members List
            List {
                ForEach(vm.members, id: \.id) { user in
                    memberRow(for: user)
                        .contentShape(Rectangle())
                        .onTapGesture { vm.remove(user) }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Colors.textActive)
                }
            }
            .listStyle(.plain)
            .background(Colors.textActive)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Inline error
            if let err = vm.inlineError {
                Text(err)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
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
                    .font(.customFont(weight: .bold, style: .body))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.2))
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
                    .font(.customFont(weight: .bold, style: .body))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(24)
                }
                .disabled(vm.groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.members.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Colors.textActive)
    }
    
    private func memberRow(for user: RowUser) -> some View {
        HStack(spacing: 12) {
            ProfileAvatarView(
                url: user.imageURL,
                name: user.username,
                config: .rowUser,
                ignoreCache: false
            )
            .frame(width: 40, height: 40)
            
            Text(user.username)
                .font(.customFont(weight: .boldItalic, style: .body))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
        }
        .padding(.vertical, 8)
        .background(Colors.textActive)
    }
}
