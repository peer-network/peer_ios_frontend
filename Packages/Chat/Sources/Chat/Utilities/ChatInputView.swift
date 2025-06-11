//
//  ChatInputView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 10/06/25.
//

import SwiftUI
import DesignSystem

struct ChatInputView: View {
    let profileImageURL: URL?
    let profileName: String
    @Binding var messageText: String
    let onSend: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {

            // 👤 Profile image
            ProfileAvatarView(
                url: profileImageURL,
                name: profileName,
                config: .message,
                ignoreCache: false)
            .frame(width: 32, height: 32)

            // 📝 Message input
            TextField("Type message", text: $messageText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            // 📤 Send button
            Button(action: {
                onSend()
            }) {
                Text("Send")
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 1)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}
