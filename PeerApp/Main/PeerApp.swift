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
import Messages
import RemoteConfig
import FirebaseMessaging
import Analytics

@main
struct PeerApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var apiManager = APIServiceManager()
    @StateObject private var authManager: AuthManager
    @StateObject private var accountManager: AccountManager = AccountManager.shared
    @StateObject private var quickLook = QuickLook.shared
    @StateObject private var audioManager = AudioSessionManager.shared

    @StateObject private var remoteConfigViewModel: RemoteConfigViewModel

    @State private var selectedTab: AppTab = .feed
    @StateObject private var appRouter = Router()

    @StateObject private var authRouter = Router()

    @State private var restoreSessionResult = AuthState.loading

    private let analyticsService: AnalyticsServiceProtocol

    init() {
        FirebaseApp.configure()
#if DEBUG
        let testConfig = APIConfiguration(endpoint: .custom)
        let testServiceManager = APIServiceManager(.normal(config: testConfig))
        _apiManager = .init(wrappedValue: testServiceManager)

        let accountManager = AccountManager.shared
        _accountManager = .init(wrappedValue: accountManager)
        accountManager.updateConfiguration(testConfig)

        _authManager = .init(wrappedValue: AuthManager(accountManager: accountManager, tokenManager: .shared))

        analyticsService = MockAnalyticsService(shouldPrintLogs: false)
        let remoteConfigService = MockRemoteConfigService()
#else
        analyticsService = FirebaseAnalyticsService()
        let remoteConfigService = FirebaseRemoteConfigService()

        _authManager = .init(wrappedValue: AuthManager(accountManager: .shared, tokenManager: .shared))
#endif
        analyticsService.track(AppEvent.launch)

        _remoteConfigViewModel = .init(wrappedValue: RemoteConfigViewModel(configService: remoteConfigService))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch remoteConfigViewModel.state {
                    case .updateRequired(let force, let message):
                        if force {
                            ForcedUpdateView(
                                message: message,
                                storeURL: remoteConfigViewModel.storeURL
                            )
                        } else {
                            contentView
                                .alert("Update Available",
                                       isPresented: $remoteConfigViewModel.showUpdateAlert) {
                                    Button("Update") {
                                        if let url = remoteConfigViewModel.storeURL {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                } message: {
                                    Text(message)
                                }
                        }
                    default:
                        contentView
                }
            }
            .task {
                await remoteConfigViewModel.fetchConfig()
            }
            .task {
                try? await ErrorCodeManager.shared.loadErrorCodes()
            }
            .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) {
            handleScenePhase(scenePhase)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch authManager.state {
            case .loading:
                ZStack(alignment: .center) {
                    Colors.textActive
                        .ignoresSafeArea()

                    LottieView(animation: .splashScreenLogo, speed: 1.2) {
                        authManager.state = restoreSessionResult
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.6)
                }
                .task {
                    restoreSessionResult = await authManager.restoreSessionIfPossible()
                }

            case .unauthenticated:
                MainAuthView(viewModel: AuthViewModel(authManager: self.authManager))
#if DEBUG
                    .overlay(alignment: .top) {
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Text("Endpoint URL: ")
                                    .foregroundStyle(Colors.whitePrimary)

                                Menu(APIConfiguration.getCustomEndpoint() ?? "not set") {
                                    Button("Test Backend - https://peer-network.eu/graphql") {
                                        APIConfiguration.setCustomEndpoint("https://peer-network.eu/graphql")
                                    }

                                    Button("Test Prod - https://getpeer.eu/graphql") {
                                        APIConfiguration.setCustomEndpoint("https://getpeer.eu/graphql")
                                    }

                                    Button("Prod - https://peernetwork.eu/graphql") {
                                        APIConfiguration.setCustomEndpoint("https://peernetwork.eu/graphql")
                                    }
                                }
                            }

                            Text("Restart the app after changing!!!")
                                .font(.customFont(weight: .regular, style: .footnote))
                                .multilineTextAlignment(.center)
                        }
                        .font(.customFont(weight: .bold, style: .callout))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(RoundedRectangle(cornerRadius: 24).fill(Colors.inactiveDark))
                        .background(RoundedRectangle(cornerRadius: 24).stroke(Colors.redAccent, lineWidth: 1))
                        .padding(.horizontal, 20)
                    }
#endif
                    .withSafariRouter()
                    .environmentObject(authRouter)
                    .environmentObject(apiManager)
                    .analyticsService(analyticsService)

            case .authenticated(let userId):
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
                    .onFirstAppear {
                        analyticsService.setUserID(userId)
                    }
                    .analyticsService(analyticsService)
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

        Messaging.messaging().delegate = notificationCenter
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.ambient, mode: .default, options: [])
        try? audioSession.setActive(true)

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
