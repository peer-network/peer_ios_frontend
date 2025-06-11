//
//  GroupChatViewModel.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//
import Foundation
import Combine

final class GroupChatViewModel: ObservableObject {
    // MARK: - Core data
    let currentUser: User
    let participants: [User]
    let groupName: String

    // The coordinator performs the real send → API call.
    private let sendAction: (String) -> Void

    // MARK: - Published state
    @Published var messages: [Message1]
    @Published var newMessage = ""
    @Published var isLoading  = false

    // MARK: - Init
    init(currentUser: User,
         participants: [User],
         groupName: String,
         initialMessages: [Message1] = [],
         sendAction: @escaping (String) -> Void) {

        self.currentUser   = currentUser
        self.participants  = participants
        self.groupName = groupName
        self.messages      = initialMessages
        self.sendAction    = sendAction
    }

    // MARK: - Sending
    @MainActor
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let text = newMessage
        newMessage = ""

        // 1️⃣ Optimistic append so UI updates instantly
        let optimistic = Message1(
            id: currentUser.id,
            text: text,
            isIncoming: false,
            timestamp: Date(),
            sender: currentUser
        )
        messages.append(optimistic)

        // 2️⃣ Delegate the real network send to the coordinator
        sendAction(text)
    }
}
extension GroupChatViewModel: ChatViewModelProtocol {
    var id: String {
        currentUser.id
    }
    
    func refreshMessages() async {
        print("test")
    }
    
    var senderName: String {
        return currentUser.name
    }
}
