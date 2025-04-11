//
//  AppCoordinator.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    let id = UUID()
    private var appInitialized: Bool?
    @Published var path: NavigationPath

    init(path: NavigationPath, appInitialized: Bool? = nil) {
        self.path = path
        self.appInitialized = appInitialized
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
    
    func initCompleted(sessionRestored: Bool) {
        self.push(AppCoordinator(path: NavigationPath(), appInitialized: sessionRestored))
    }
    
    func authCompleted() {
        self.push(AppCoordinator(path: NavigationPath(), appInitialized: true))
    }
    
    private func startSplashScreen() -> some View {
        SplashModule()
    }
    
    private func startAuthModule() -> some View {
        AuthModule()
    }
    
    private func startMainModule() -> some View {
        print(path)
        return Color.yellow
        
    }
    
    private func startEmptyView() -> some View {
        EmptyView()
    }
    
    private func push<V>(_ value: V) where V : Hashable {
        path.append(value)
    }
}

extension AppCoordinator: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppCoordinator, rhs: AppCoordinator) -> Bool {
        lhs.id == rhs.id
    }
}
