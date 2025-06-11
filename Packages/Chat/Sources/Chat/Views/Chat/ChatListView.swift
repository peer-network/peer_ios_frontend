//
//  ChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//

import SwiftUI
import Models
import Environment

struct ChatListView: View {
    let chats: [ListChats]
    let onChatSelected: (ListChats) -> Void
    let isGroupChat: Bool
    
    var body: some View {
        List(chats) { chat in
            ChatItemView(chat: chat, isGroupChat: isGroupChat)
                .onTapGesture { onChatSelected(chat) }
        }
        .listStyle(.plain)
    }
}

struct ChatItemView: View {
    let chat: ListChats
    let isGroupChat: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Unified avatar view
            ChatAvatarView(chat: chat, isGroupChat: isGroupChat)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(chatDisplayName)
                    .font(.headline)
                Text(chatSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var chatDisplayName: String {
        isGroupChat ? (chat.name ?? "Unnamed group") : (peer?.username ?? "")
    }
    
    private var chatSubtitle: String {
        if isGroupChat {
            return "\(chat.chatParticipants.count) members"
        } else {
            return chat.chatMessages.last?.content ?? "Tap to start chatting"
        }
    }
    
    private var peer: ChatParticipant? {
        chat.chatParticipants.first { $0.userId != AccountManager.shared.userId }
    }
}
