//
//  PushNotificationCenter.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import UserNotifications
import FirebaseMessaging

public final class PushNotificationCenter: NSObject {
}

extension PushNotificationCenter: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner]
    }
    
    @MainActor
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let action = PushNotifications.ActionIdentifier(rawValue: response.actionIdentifier) else { return }
        switch action {
            case .reply:
                if let reply = response as? UNTextInputNotificationResponse {
                    print(reply.userText)
                    // TODO: Add sendMessage action here
                }
        }
    }
}

extension PushNotificationCenter: MessagingDelegate {

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            Messaging.messaging().token { token, error in
              if let error = error {
                print("Error fetching FCM registration token: \(error)")
              } else if let token = token {
                print("FCM registration token: \(token)")
              }
            }
        }
}
