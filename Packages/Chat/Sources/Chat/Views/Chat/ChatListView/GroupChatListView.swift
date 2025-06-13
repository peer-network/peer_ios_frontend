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
        ChatListView(
            chats: chats,
            isGroupChat: true,
            onChatSelected: onChatSelected
        )
    }
}
