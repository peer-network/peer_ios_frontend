//
//  MainModule.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 14.04.25.
//

import SwiftUICore
import Environment

struct MainModule: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    @StateObject private var audioManager = AudioSessionManager.shared
    @StateObject private var accountManager = AccountManager.shared
    @StateObject private var apiManager = APIServiceManager()
    @StateObject private var appRouter = Router()
    @State private var selectedTab: AppTab = .feed
    
    var body: some View {
        Group {
            MainCoordinator(
                navigationPath: $appCoordinator.path,
                transitions: .init(logout: {
                    appCoordinator.logout()
                })
            ).view(selectedTab: $selectedTab, appRouter: appRouter)
                .environmentObject(audioManager)
                .environmentObject(accountManager)
                .environmentObject(apiManager)
        }
    }
}
