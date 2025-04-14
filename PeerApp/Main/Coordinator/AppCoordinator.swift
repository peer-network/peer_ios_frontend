//
//  AppCoordinator.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    let id: UUID
    @Published var path: NavigationPath
    @Published private var appInitialized: Bool?

    init(path: NavigationPath) {
        self.id = UUID()
        self.path = path
    }
    
    @ViewBuilder
    func view() -> some View {
        switch appInitialized {
        case .none:
            startSplashScreen()
        case .some(let sessionRestored):
            if sessionRestored {
                startMainModule()
            } else {
                startAuthModule()
            }
        }
    }
    
    ///After attempt to restore session coordinator updates it's @Published property and reevaluate @ViewBuilder view()
    func initCompleted(sessionRestored: Bool) {
        appInitialized = sessionRestored
    }
    
    ///After successful login coordinator updates it's @Published property and reevaluate @ViewBuilder view()
    func authCompleted() {
        appInitialized = true
    }
    
    ///After logout coordinator updates it's @Published property and reevaluate @ViewBuilder view()
    func logout() {
        appInitialized = false
    }
    
    private func startSplashScreen() -> some View {
        SplashModule()
    }
    
    private func startAuthModule() -> some View {
        AuthModule()
    }
    
    private func startMainModule() -> some View {
        MainModule()
    }
}
