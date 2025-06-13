//
//  ChatType.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

enum ChatType {
    case privateChat
    case groupChat
}
extension ChatType {
    var navigationTitle: String {
        switch self {
        case .privateChat: return "Chats"
        case .groupChat: return "Group Chats"
        }
    }
    
    var emptyStateMessage: String {
        switch self {
        case .privateChat: return "No chats available"
        case .groupChat: return "No group chats available"
        }
    }
}
