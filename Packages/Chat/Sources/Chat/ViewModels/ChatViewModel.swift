//
//  ChatViewModel.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//

import Foundation
import Combine

enum ChatMessageType {
    case `private`(peer: User)
    case group(participants: [User], name: String)
}

final class ChatViewModel: ObservableObject {
    // Shared Properties
    let currentUser: User
    let chatType: ChatMessageType
    @Published var messages: [Message1] = []
    @Published var newMessage = ""
    @Published var isLoading = false
    
    // Coordinator Callback
    private let sendAction: (String) -> Void
    
    // Computed Properties
    var displayTitle: String {
        switch chatType {
        case .private(let peer): return peer.name
        case .group(_, let name): return name
        }
    }
    
    var senderName: String {
        switch chatType {
        case .private: return currentUser.name
        case .group: return currentUser.name
        }
    }
    
    init(currentUser: User,
         chatType: ChatMessageType,
         initialMessages: [Message1] = [],
         sendAction: @escaping (String) -> Void) {
        self.currentUser = currentUser
        self.chatType = chatType
        self.messages = initialMessages
        self.sendAction = sendAction
    }
    
    @MainActor
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let text = newMessage
        newMessage = ""
        
        let message = Message1(
            id: currentUser.id,
            text: text,
            isIncoming: false,
            timestamp: "",
            sender: currentUser
        )
        messages.append(message)
        sendAction(text)
    }
}
