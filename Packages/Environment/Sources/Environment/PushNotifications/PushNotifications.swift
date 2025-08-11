//
//  PushNotifications.swift
//  Environment
//
//  Created by Артем Васин on 20.12.24.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import FirebaseFirestoreInternal
import FirebaseFunctions

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

            //            try await Messaging.messaging().subscribe(toTopic: "user_4cca9cfe-762b-416f-8e15-571f4d6798c9") { error in
            //                if let e = error {
            //                  print("🔴 topic subscribe failed:", e)
            //                } else {
            //                  print("🟢 subscribed to topic user_4cca9cfe-762b-416f-8e15-571f4d6798c9")
            //                }
            //              }
        }
    }

    public static func registerFCMToken(for userID: String) async {
        let token = try? await Messaging.messaging().token()

        if let token {
            let userRef = Firestore.firestore().collection("users").document(userID)
            try? await userRef.setData([
                "fcmTokens": FieldValue.arrayUnion([token])
            ], merge: true)
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


public class NotificationService {
    private static var functions = Functions.functions()

    public static func sendLikeNotification(
        username: String,
        postTitle: String,
        targetUid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data: [String: Any] = [
            "action":    "like",
            "username":  username,
            "postTitle": postTitle,
            "targetUid": targetUid
        ]

        functions.httpsCallable("sendUserNotification")
            .call(data) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    private static func deleteFCMToken(completion: @escaping (Error?) -> Void) {
        Messaging.messaging().deleteToken { error in
            if let err = error {
                print("❌ Failed to delete FCM token:", err)
                completion(err)
            } else {
                print("✅ FCM token deleted locally")
                completion(nil)
            }
        }
    }

    private static func unregisterForPushNotifications(uid: String, completion: @escaping (Error?) -> Void) {
        Messaging.messaging().token { token, error in
            if let err = error {
                print("⚠️ Couldn't fetch FCM token:", err)
                completion(err)
                return
            }
            guard let token = token else {
                print("⚠️ No FCM token to delete")
                completion(nil)
                return
            }
            let userRef = Firestore.firestore()
                .collection("users")
                .document(uid)
            // Remove this device's token from Firestore
            userRef.updateData([
                "fcmTokens": FieldValue.arrayRemove([token])
            ]) { err in
                if let err = err {
                    print("❌ Failed to remove token from Firestore:", err)
                    completion(err)
                } else {
                    print("✅ Removed FCM token from Firestore")
                    completion(nil)
                }
            }
        }
    }

    static public func logoutUser(userId: String) {
        NotificationService.unregisterForPushNotifications(uid: userId) { _ in
            NotificationService.deleteFCMToken { _ in
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            }
        }
    }
}
