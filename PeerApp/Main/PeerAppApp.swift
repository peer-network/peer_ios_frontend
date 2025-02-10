//
//  PeerAppApp.swift
//  PeerApp
//
//  Created by Артем Васин on 13.12.24.
//

import SwiftUI
import Networking
import GQLOperationsUser
import Environment
import AVFAudio
import DesignSystem
import MediaUI
import Auth

@main
struct PeerAppApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var userPreferences = UserPreferences.shared
    @StateObject private var theme = Theme.shared
    @StateObject private var accountManager = AccountManager.shared
    @StateObject private var quickLook = QuickLook.shared
    
    @State private var selectedTab: AppTab = .feed
    @StateObject private var appRouter = Router()
    
    var body: some Scene {
        WindowGroup {
            switch authManager.state {
                case .loading:
                    Text("Loading...")
                        .task {
                            await authManager.restoreSessionIfPossible()
                        }
                    
                case .unauthenticated:
                    MainAuthView()
                        .environmentObject(authManager)
                    
                case .authenticated(_):
                    ContentView(selectedTab: $selectedTab, appRouter: appRouter)
                        .applyTheme(theme)
                        .environmentObject(userPreferences)
                        .environmentObject(theme)
                        .environmentObject(accountManager)
                        .environmentObject(quickLook)
                        .sheet(item: $quickLook.selectedMediaAttachment) { selectedMediaAttachment in
                            MediaUIView(data: quickLook.mediaAttachments, initialItem: selectedMediaAttachment)
                                .presentationBackground(.ultraThinMaterial)
                                .presentationCornerRadius(16)
                                .withEnvironments()
                        }
            }
        }
        .onChange(of: scenePhase) {
            handleScenePhase(scenePhase)
        }
    }
    
    private func handleScenePhase(_ scenePhase: ScenePhase) {
        switch scenePhase {
            case .background:
                break
            case .inactive:
                break
            case .active:
                clearBadgeCount()
            default:
                break
        }
    }
    
    private func clearBadgeCount() {
        UserDefaults.extensions.badge = 0
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - UIApplicationDelegate class

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationCenter = PushNotificationCenter()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        PushNotifications.register(in: application, using: notificationCenter)
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback)
        try? audioSession.setActive(true, options: [])
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotifications.send(token: deviceToken, to: Config.pushesRegistrationURL)
        PushNotifications.registerCustomActions()
    }
}
