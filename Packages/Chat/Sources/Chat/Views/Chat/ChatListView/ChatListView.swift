//
//  ChatListView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//

import SwiftUI
import Models
import DesignSystem

struct ChatListView: View {
    let chats: [ListChats]
    let isGroupChat: Bool
    let onChatSelected: (ListChats) -> Void
    var onAddTapped: (() -> Void)? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
//                if isGroupChat {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            onAddTapped?()
//                        }) {
//                            Image(systemName: "plus.circle.fill")
//                                .font(.title)
//                                .foregroundColor(.blue)
//                        }
//                        .padding(.trailing)
//                    }
//                }
                
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
