//
//  PeerAppAlt.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI
import Environment

//@main
struct PeerAppAlt: App {
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    
    var body: some Scene {
        WindowGroup {
            appCoordinator.view()
                .environmentObject(appCoordinator)
        }
    }
}
