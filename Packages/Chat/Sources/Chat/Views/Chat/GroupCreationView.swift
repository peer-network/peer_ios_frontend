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
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSubmitting = false
    var onCreateSuccess: (() -> Void)?
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                Text("Create Group Chat")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Group Name Field
                TextField("*Give a name to chat", text: $vm.groupName)
                    .padding(.leading, 44)
                    .padding(.vertical, 12)
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
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
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
                            vm.onAddAccounts()
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
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(24)
                    }
                    
                    // Create Chat Button
                    Button(action: {
                        createChatAction()
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
                    .disabled(vm.groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.members.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .background(Colors.textActive)
            }
            .background(Colors.textActive)
            .ignoresSafeArea()
            .toast(isShowing: $vm.showSuccessToast, message: "Group created successfully")
            
            // Progress overlay when creating
            if isSubmitting {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Creating group…")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
        // Listen to vm's state changes and update UI accordingly
        .onChange(of: vm.isSubmitting) { creating in
            isSubmitting = creating
        }
        .onChange(of: vm.showSuccessToast) { shown in
                    if shown {
                        DispatchQueue.main.async() {
                            onCreateSuccess?()
                        }
                    }

    }
    
//        .onChange(of: vm.isCreating) { creating in
//            isCreating = creating
//        }
//        .onChange(of: vm.showSuccessToast) { shown in
//            if shown {
//                // After toast is shown, dismiss view after a delay
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    dismiss()
//                }
//            }
//        }
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
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
        }
        .padding(.vertical, 8)
        .background(Colors.textActive)
        .cornerRadius(8)
    }
    
    private func createChatAction() {
        vm.createChat()
    }
}

