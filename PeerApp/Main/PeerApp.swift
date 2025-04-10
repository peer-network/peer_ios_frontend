//
//  PeerApp.swift
//  PeerApp
//
//  Created by Артем Васин on 13.12.24.
//

import SwiftUI
import Models
import Environment
import AVFAudio
import DesignSystem
import MediaUI
import Auth
import FirebaseCore
import FirebaseAnalytics
import Messages
import RemoteConfig
import FirebaseMessaging

@main
struct PeerApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var apiManager = APIServiceManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var accountManager = AccountManager.shared
    @StateObject private var quickLook = QuickLook.shared
    @StateObject private var audioManager = AudioSessionManager.shared

    @State private var selectedTab: AppTab = .feed
    @StateObject private var appRouter = Router()

    @State private var showUpdateAlert: Bool = false

    @StateObject private var authRouter = Router()

    @State private var restoreSessionResult = AuthState.loading

    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.state {
                    case .loading:
                        ZStack(alignment: .center) {
                            Colors.textActive
                                .ignoresSafeArea()

                            LottieView(animation: .splashScreenLogo) {
                                authManager.state = restoreSessionResult
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.6)
                        }
                        .task {
                            restoreSessionResult = await authManager.restoreSessionIfPossible()
                        }
                        
                    case .unauthenticated:
                    MainAuthView(viewModel: AuthViewModel(authManager: self.authManager))
                            .withSafariRouter()
                            .environmentObject(authRouter)
                            .environmentObject(apiManager)

                    case .authenticated(_):
                        ContentView(selectedTab: $selectedTab, appRouter: appRouter)
                            .environmentObject(apiManager)
                            .environmentObject(accountManager)
                            .environmentObject(quickLook)
                            .environmentObject(authManager)
                            .environmentObject(audioManager)
                            .sheet(item: $quickLook.selectedMediaAttachment) { selectedMediaAttachment in
                                MediaUIView(data: quickLook.mediaAttachments, initialItem: selectedMediaAttachment)
                                    .presentationBackground(.ultraThinMaterial)
                                    .presentationCornerRadius(16)
                                    .withEnvironments()
                                    .preferredColorScheme(.dark)
                            }
                }
            }
            .onAppear {
                showUpdateAlert = RemoteConfigService.shared.checkIfUpdateRequired()
            }
            .alert("New version available", isPresented: $showUpdateAlert) {
                updateAlertButton
            } message: {
                Text("There are new features available, please update your app.")
            }
            .preferredColorScheme(.dark)
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

    private var updateAlertButton: some View {
        Button("Update", role: .none) {
            if let url = RemoteConfigService.shared.storeUrl {
                UIApplication.shared.open(url)
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1))
                showUpdateAlert = true
            }
        }
    }
}

// MARK: - UIApplicationDelegate class

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationCenter = PushNotificationCenter()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        RemoteConfigService.shared.fetchAndActivate()

        PushNotifications.register(in: application, using: notificationCenter)

        Messaging.messaging().delegate = notificationCenter

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.ambient, mode: .default, options: [])
        try? audioSession.setActive(true)

        Analytics.logEvent("app_started", parameters: nil)

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotifications.send(token: deviceToken, to: Config.pushesRegistrationURL)
        PushNotifications.registerCustomActions()
        PushNotifications.setFirebaseToken(deviceToken)
    }
}
