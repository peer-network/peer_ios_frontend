//
//  ChatDetail.swift
//  Models
//
//  Created by Siva kumar Aketi on 06/06/25.
//

import Foundation
import GQLOperationsUser


public struct ListChatMessages: Hashable {
    public let status: String
    public let counter: Int
    public let responseCode: String?
    public let messages: [ChatDetailMessage]

    public init(
        status: String,
        counter: Int,
        responseCode: String?,
        messages: [ChatDetailMessage]
    ) {
        self.status = status
        self.counter = counter
        self.responseCode = responseCode
        self.messages = messages
    }
}

public struct ChatDetailMessage:  Hashable {
    public let chatId: String
    public let content: String
    public let createdAt: String?
    public let messid: ID
    public let userid: String

    public init(
        userid: String,
        messid: String,
        chatId: String,
        content: String,
        createdAt: String?
    ) {
        self.userid  = userid
        self.messid  = messid
        self.chatId    = chatId
        self.content   = content
        self.createdAt = createdAt
    }

//    public init?(
//        gqlMessage: ListChatMessagesQuery.Data.listChatMessages.affectedRows
//    ) {
//        self.init(
//            chatid:        gqlMessage.chatid,
//                    messid:  gqlMessage.messid,
//                    chatId:    gqlMessage.chatid,
//                    content:   gqlMessage.content,
//                    createdAt: gqlMessage.createdat
//                )
//    }
}
