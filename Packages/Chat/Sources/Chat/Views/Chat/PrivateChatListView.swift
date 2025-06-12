//
//  PrivateChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 06/06/25.
//

import SwiftUI
import Models
import Environment
import DesignSystem

struct PrivateChatListView: View {
    let chats: [ListChats]
    var onChatSelected: (ListChats) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(chats) { chat in
                    Button(action: {
                        onChatSelected(chat)
                    }) {
                        row(for: chat)
                            .padding()
                            .background(Colors.textActive)
                            //.cornerRadius(16)
                            //.shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Colors.textActive.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func row(for chat: ListChats) -> some View {
        if let peer = chat.chatParticipants.first(where: { $0.userId != AccountManager.shared.userId }) {
            HStack(spacing: 12) {
                AsyncImage(url: peer.imageURL) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        Image(systemName: "person.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(peer.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if let createdAt = chat.createdAt {
                            Text(createdAt.timeAgo(isShort: true))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let last = chat.chatMessages.last {
                        Text(last.content)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    } else {
                        Text("Tap to start chatting")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
