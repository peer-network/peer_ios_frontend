//
//  GroupChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 06/06/25.
//

import SwiftUI
import Models
import Environment
import DesignSystem

struct GroupChatListView: View {
    let chats: [ListChats]
    let onChatSelected: (ListChats) -> Void
    let onAddTapped: () -> Void

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
        HStack(spacing: 12) {
            avatar(for: chat)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name ?? "Unnamed group")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let createdAt = chat.createdAt {
                        Text(createdAt.timeAgo(isShort: true))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Text("\(chat.chatParticipants.count) members")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let lastMessage = chat.chatMessages.last {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else {
                    Text("No messages yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    @ViewBuilder
    private func avatar(for chat: ListChats) -> some View {
        if let url = chat.imageURL {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if phase.error != nil {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.2.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
        }
    }
}
