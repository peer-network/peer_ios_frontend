//
//  PushNotifications.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import UIKit
import UserNotifications
import FirebaseMessaging

public enum PushNotifications {
    private static let categoryIdentifier = "reply"
    
    enum ActionIdentifier: String {
        case reply
    }
    
    public static func send(token: Data, to url: String) {
        guard let url = URL(string: url) else { return }
        Task {
            let details = PushToken(token: token)
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = details.encoded()
            
            _ = try await URLSession.shared.data(for: request)
        }
    }
    
    public static func register(
        in application: UIApplication,
        using notificationDelegate: UNUserNotificationCenterDelegate? = nil
    ) {
        Task {
            let center = UNUserNotificationCenter.current()
            // Requesting access for Notifications immediately
            try await center.requestAuthorization(options: [.badge, .sound, .alert])
            
            center.delegate = notificationDelegate

            await MainActor.run {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    public static func registerCustomActions() {
        let identifier = ActionIdentifier.reply.rawValue
        
        let replyAction = UNTextInputNotificationAction(identifier: identifier, title: "Reply", textInputButtonTitle: "Reply", textInputPlaceholder: "Message")
        
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [replyAction], intentIdentifiers: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    public static func setFirebaseToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
}
