//
//  ChatListItemView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 13/06/25.
//

import SwiftUI
import Models
import DesignSystem
import Environment

struct ChatListItemView: View {
    let chat: ListChats
    let isGroupChat: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            avatarView
            
            VStack(alignment: .leading, spacing: 4) {
                headerView
                
                if isGroupChat {
                    Text("\(chat.chatParticipants.count) members")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                messagePreviewView
            }
        }
    }
    
    // MARK: - Subviews
    
    private var avatarView: some View {
        Group {
            if isGroupChat {
                ProfileAvatarView(
                    url: chat.imageURL,
                    name: chat.name ?? "Group",
                    config: .message,
                    ignoreCache: false
                )
            } else if let peer = chat.chatParticipants.first(where: { $0.userId != AccountManager.shared.userId }) {
                ProfileAvatarView(
                    url: peer.imageURL,
                    name: peer.username,
                    config: .message,
                    ignoreCache: false
                )
            }
        }
        .frame(width: 48, height: 48)
    }
    
    private var headerView: some View {
        HStack {
            Text(isGroupChat ? (chat.name ?? "Unnamed group") : peerUsername)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            if let createdAt = chat.createdAt {
                Text(createdAt.timeAgo(isShort: true))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var messagePreviewView: some View {
        Group {
            if let lastMessage = chat.chatMessages.last {
                Text(lastMessage.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            } else {
                Text(isGroupChat ? "No messages yet" : "Tap to start chatting")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var peerUsername: String {
        chat.chatParticipants.first(where: { $0.userId != AccountManager.shared.userId })?.username ?? "Unknown"
    }
}
