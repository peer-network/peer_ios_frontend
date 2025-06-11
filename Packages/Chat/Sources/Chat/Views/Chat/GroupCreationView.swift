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
        VStack(spacing: 16) {

            // ── title field ───────────────────────────
            TextField("*Give a name to a chat", text: $vm.groupName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .autocapitalization(.none)
                .disableAutocorrection(true)

            // ── members list ──────────────────────────
            ScrollView {
                ForEach(vm.members, id: \.id) { user in
                    HStack {
                        ProfileAvatarView(
                            url: user.imageURL,
                            name: user.username,
                            config: .rowUser,
                            ignoreCache: false
                        )
                        Text(user.username)
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            vm.remove(user)
                        } label: {
                            Image(systemName: "minus")
                                .foregroundColor(.white)
                                .frame(width: 32, height: 6) // thin bar
                        }
                        .background(Color.white.opacity(0.4))
                        .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }

            // ── inline error ──────────────────────────
            if let err = vm.inlineError {
                Text(err)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            // ── bottom buttons ────────────────────────
            HStack(spacing: 0) {

                Button("Add accounts") { vm.onAddAccounts() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor))

                Button {
                    vm.createChat()
                } label: {
                    HStack {
                        Text("Create chat")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(vm.isSubmitting)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}
