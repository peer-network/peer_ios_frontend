//
//  PrivateChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 06/06/25.
//

//  PrivateChatListView.swift
//  Chat

import SwiftUI
import Models
import Environment
import DesignSystem

struct PrivateChatListView: View {
    let chats: [ListChats]
    var onChatSelected: (ListChats) -> Void
    
    var body: some View {
        List(chats) { chat in
            row(for: chat)
                .contentShape(Rectangle())
                .onTapGesture {
                    onChatSelected(chat)
                }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func row(for chat: ListChats) -> some View {
        if let peer = chat.chatParticipants.first(where: { $0.userId != AccountManager.shared.userId }) {
            HStack(spacing: 12) {
                AsyncImage(url: peer.imageURL) {
                    $0.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .top) {
                        Text(peer.username)
                            .font(.headline)
                        
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
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Tap to start chatting")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// Extension for time formatting (add this if you don't have it already)
extension String {
    func timeAgo() -> String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: self) else { return self }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
