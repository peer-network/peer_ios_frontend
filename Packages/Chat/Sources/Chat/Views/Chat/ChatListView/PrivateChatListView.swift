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
        ChatListView(
            chats: chats,
            isGroupChat: false,
            onChatSelected: onChatSelected
        )
    }
}
