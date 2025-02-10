//
//  NotificationService.swift
//  PayloadModification
//
//  Created by Артем Васин on 14.12.24.
//

import UserNotifications
import Intents

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else { return }
        
        updateBadge(bestAttemptContent)
        
        let categoryIdentifier = bestAttemptContent.categoryIdentifier
        if categoryIdentifier == "reply" {
            Task {
                await updateCommunicationNotification(bestAttemptContent, contentHandler: contentHandler)
            }
        } else {
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.body = "Sent you a new message"
            contentHandler(bestAttemptContent)
        }
    }
    
    private func updateCommunicationNotification(_ bestAttemptContent: UNMutableNotificationContent, contentHandler: @escaping (UNNotificationContent) -> Void) async {
        
        guard
            let userInfo = bestAttemptContent.userInfo as? [String: Any],
            let senderId = userInfo["sender-id"] as? String,
            !senderId.isEmpty,
            let chatId = userInfo["chat-id"] as? String,
            !chatId.isEmpty,
            let avatarUrlPath = userInfo["avatar-url"] as? String,
            let avatarUrl = URL(string: avatarUrlPath)
        else {
            bestAttemptContent.body = "Sent you a new message"
            contentHandler(bestAttemptContent)
            return
        }

        var avatar: INImage?
        
        if let (data, _) = try? await URLSession.shared.data(from: avatarUrl) {
            avatar = INImage(imageData: data)
        }
        
        let handle = INPersonHandle(value: senderId, type: .unknown)
        
        let sender = INPerson(personHandle: handle, nameComponents: nil, displayName: bestAttemptContent.title, image: avatar, contactIdentifier: nil, customIdentifier: nil, isMe: false, suggestionType: .socialProfile)
        
        if let groupChatName = bestAttemptContent.userInfo["chat-name"] as? String {
            // add recipients, set speakable group name
            
        }
        
        let intent = INSendMessageIntent(recipients: nil, outgoingMessageType: .outgoingMessageText, content: bestAttemptContent.body, speakableGroupName: INSpeakableString(spokenPhrase: "Something"), conversationIdentifier: chatId, serviceName: nil, sender: sender, attachments: nil)
        intent.setImage(avatar, forParameterNamed: \.sender)
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        
        do {
            try await interaction.donate()
        } catch {
            print(error)
            return
        }
        
        do {
            let updatedContent = try bestAttemptContent.updating(from: intent)
            contentHandler(updatedContent)
        } catch {
            print(error)
            return
        }
    }
    
    private func updateBadge(_ bestAttemptContent: UNMutableNotificationContent) {
        guard let increment = bestAttemptContent.badge as? Int else { return }
        
        if increment == 0 {
            UserDefaults.extensions.badge = 0
            bestAttemptContent.badge = 0
        } else {
            let current = UserDefaults.extensions.badge
            let new = current + increment
            
            UserDefaults.extensions.badge = new
            bestAttemptContent.badge = NSNumber(value: new)
        }
    }
}
