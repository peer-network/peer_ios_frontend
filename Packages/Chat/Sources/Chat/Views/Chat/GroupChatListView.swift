//
//  GroupChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 06/06/25.
//

import SwiftUI
import Models

struct GroupChatListView: View {
    let chats: [ListChats]
    let onChatSelected: (ListChats) -> Void
    let onAddTapped: () -> Void

    var body: some View {
        List(chats) { chat in
            Button {
                onChatSelected(chat)
            } label: {
                HStack(spacing: 12) {
                    avatar(for: chat)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chat.name ?? "Unnamed group")
                            .font(.headline)
                        Text("\(chat.chatParticipants.count) members")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func avatar(for chat: ListChats) -> some View {
        if let url = chat.imageURL {
            AsyncImage(url: url) { img in
                img.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
        }
    }
    
}
