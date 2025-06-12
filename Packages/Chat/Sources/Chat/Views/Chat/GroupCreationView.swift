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
            HStack(spacing: 16) {
                            // Add Members button (light blue)
                            Button(action: vm.onAddAccounts) {
                                HStack {
                                    Text("Add Members")
                                    Image(systemName: "plus.circle.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                
                            }
                            
                            // Create button (solid blue)
                            Button(action: vm.createChat) {
                                HStack {
                                    Text("Create")
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .background(vm.isValid ? Color.blue : Color.gray)
                            }
                            .disabled(!vm.isValid || vm.isSubmitting)
                        }
            
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
        .toast(isShowing: $vm.showSuccessToast, message: "Group created successfully") // Moved here
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
