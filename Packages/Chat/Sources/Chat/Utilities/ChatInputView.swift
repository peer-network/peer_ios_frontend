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
        HStack(alignment: .center, spacing: 12) {
            // 👤 Profile image
            ProfileAvatarView(
                url: profileImageURL,
                name: profileName,
                config: .settings,
                ignoreCache: false
            )
            .frame(width: 36, height: 36)
            
            // 📝 Message input with built-in send button
            HStack {
                TextField("", text: $messageText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal, 16)
                    .frame(minHeight: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(25)
                    .overlay(
                        Group {
                            if messageText.isEmpty {
                                Text("Write a message...")
                                    .foregroundColor(Color(.systemGray2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16)
                            }
                        }
                    )
                
                // Send button
                if !messageText.isEmpty {
                    Button(action: onSend) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 8)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .animation(.default, value: messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}
