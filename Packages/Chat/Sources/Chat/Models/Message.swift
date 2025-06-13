//
//  Message.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//
import SwiftUI
import Models

struct Message: Hashable, Identifiable {
    let id = UUID()
    let text: String
    let isIncoming: Bool
    let timestamp: Date
    let sender: RowUser
}
