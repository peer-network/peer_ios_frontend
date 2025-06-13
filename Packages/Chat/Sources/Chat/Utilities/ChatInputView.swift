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
            // Profile image
            ProfileAvatarView(
                url: profileImageURL,
                name: profileName,
                config: .settings,
                ignoreCache: false
            )
            
            // Message input with integrated send button
            ZStack(alignment: .trailing) {
                TextField("", text: $messageText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal, 16)
                    .padding(.trailing, 45)
                    .frame(minHeight: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(25)
//                    .overlay(
//                        Group {
//                            if messageText.isEmpty {
//                                Text("Write a message...")
//                                    .foregroundColor(Color(.systemGray2))
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 16)
//                            }
//                        }
//                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                // Send button using Colors.hashtag
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(Colors.hashtag)
                            .frame(width: 45, height: 45)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 30, weight: .regular))
                           // .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 8)
                .disabled(messageText.isEmpty)
                .opacity(messageText.isEmpty ? 0.5 : 1.0)
            }
            .animation(.easeInOut, value: messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Colors.textActive)
    }
}
