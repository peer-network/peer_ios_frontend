//
//  ChatViewModelProtocol.swift.swift
//  Chat
//
//  Created by Siva kumar Aketi on 11/06/25.
//

import Foundation
import SwiftUI

protocol ChatViewModelProtocol: ObservableObject {
    var messages: [Message1] { get }
    var newMessage: String { get set }
    var isLoading: Bool { get }
    var senderName: String { get }
    var id: String { get }
    
    func sendMessage()
    @MainActor func refreshMessages() async
}
