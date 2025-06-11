//
//  ChatServiceProtocol.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import Models
import GQLOperationsUser

protocol ChatServiceProtocol {
   // func sendMessage(_ message: Message, completion: @escaping (Bool) -> Void)
    func listChats() async throws -> [ListChats]
        func listMessages(for chatId: String) async throws -> [ChatMessage]
        func sendMessage(chatId: String, content: String) async throws
        func subscribe(to chatId: String) -> AsyncStream<ChatMessage>
}
