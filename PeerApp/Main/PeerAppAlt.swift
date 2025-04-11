//
//  PeerAppAlt.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI

@main
struct PeerAppAlt: App {
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.path) {
                appCoordinator.view()
                    .navigationDestination(for: AppCoordinator.self) { coordinator in
                        coordinator.view()
                    }
            }
            .environmentObject(appCoordinator)
        }
    }
}
