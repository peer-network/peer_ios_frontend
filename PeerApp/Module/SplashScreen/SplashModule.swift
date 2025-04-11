//
//  MainView.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI

struct SplashModule: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator

    var body: some View {
        Group {
            SplashCoordinator(
                navigationPath: $appCoordinator.path,
                transitions: .init(initCompleted: appCoordinator.initCompleted(sessionRestored:))
            ).view()
        }
    }
}

#Preview {
    SplashModule()
}
