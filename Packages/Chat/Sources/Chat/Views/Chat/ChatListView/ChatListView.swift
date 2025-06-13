//
//  ChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//

import SwiftUI
import Models
import Environment
import DesignSystem

struct ChatListView<Header: View>: View {
    let chats: [ListChats]
    let isGroupChat: Bool
    let onChatSelected: (ListChats) -> Void
    var header: (() -> Header)? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let header = header {
                    header()
                }
                
                ForEach(chats) { chat in
                    Button(action: {
                        onChatSelected(chat)
                    }) {
                        ChatListItemView(chat: chat, isGroupChat: isGroupChat)
                            .padding()
                            .background(Colors.textActive)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Colors.textActive.ignoresSafeArea())
    }
}

// Default implementation without header
extension ChatListView where Header == EmptyView {
    init(chats: [ListChats], isGroupChat: Bool, onChatSelected: @escaping (ListChats) -> Void) {
        self.init(chats: chats, isGroupChat: isGroupChat, onChatSelected: onChatSelected, header: nil)
    }
}
