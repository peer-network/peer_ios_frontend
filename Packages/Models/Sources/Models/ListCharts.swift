//
//  ListChats.swift
//  Models
//
//  Created by Siva kumar Aketi on 05/06/25.
//  Revised 05/06/25 to remove Codable and align with User model style.
//

// MARK: - ListChats.swift -----------------------------------------------------

import Foundation
import GQLOperationsUser

public struct ListChats: Identifiable, Hashable {
    public let id: String
    public let image: String?
    public let name: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let chatMessages: [ChatMessage]
    public let chatParticipants: [ChatParticipant]

    public var imageURL: URL? {
        guard let image, !image.isEmpty else { return nil }
        return URL(string: "\(Constants.mediaURL)\(image)")
    }

    // Designated initialiser
    public init(
        id: String,
        image: String?,
        name: String?,
        createdAt: String?,
        updatedAt: String?,
        chatMessages: [ChatMessage],
        chatParticipants: [ChatParticipant]
    ) {
        self.id               = id
        self.image            = image
        self.name             = name
        self.createdAt        = createdAt
        self.updatedAt        = updatedAt
        self.chatMessages     = chatMessages
        self.chatParticipants = chatParticipants
    }

    // Convenience initialiser from Apollo type
    public init?(
        gqlChat: ListChatsQuery.Data.ListChats.AffectedRow
    ) {
//        guard
//            let id   = gqlChat.id,
//            let name = gqlChat.name
//        else { return nil }

        self.id        = gqlChat.id
        self.name      = gqlChat.name
        self.image     = gqlChat.image
        self.createdAt = gqlChat.createdat
        self.updatedAt = gqlChat.updatedat
        self.chatMessages     = gqlChat.chatmessages
            .compactMap(ChatMessage.init(gqlMessage:))
        self.chatParticipants = gqlChat.chatparticipants
            .compactMap(ChatParticipant.init(gqlParticipant:))
    }
}

public struct ChatMessage: Identifiable, Hashable {
    public let id: String
    public let senderId: String
    public let chatId: String
    public let content: String
    public let createdAt: String?

    public init(
        id: String,
        senderId: String,
        chatId: String,
        content: String,
        createdAt: String?
    ) {
        self.id        = id
        self.senderId  = senderId
        self.chatId    = chatId
        self.content   = content
        self.createdAt = createdAt
    }

    public init?(
        gqlMessage: ListChatsQuery.Data.ListChats.AffectedRow.Chatmessage
    ) {
        self.init(
                    id:        gqlMessage.id,
                    senderId:  gqlMessage.senderid,
                    chatId:    gqlMessage.chatid,
                    content:   gqlMessage.content,
                    createdAt: gqlMessage.createdat
                )
    }
}

public struct ChatParticipant: Hashable {
    public let userId: String
    public let img: String?
    public let username: String
    public let slug: Int
    public let hasAccess: Int

    public var imageURL: URL? {
        guard let img, !img.isEmpty else { return nil }
        return URL(string: "\(Constants.mediaURL)\(img)")
    }

    // Designated initializer
    public init(
        userId: String,
        img: String?,
        username: String,
        slug: Int,
        hasAccess: Int
    ) {
        self.userId = userId
        self.img = img
        self.username = username
        self.slug = slug
        self.hasAccess = hasAccess
    }

    // Failable initializer from GraphQL type
    public init?(
        gqlParticipant: ListChatsQuery.Data.ListChats.AffectedRow.Chatparticipant
    ) {
    
            self.userId = gqlParticipant.userid
            self.img = gqlParticipant.img
            self.username = gqlParticipant.username
            self.slug = gqlParticipant.slug
            self.hasAccess = gqlParticipant.hasaccess
        
    }
}
