//
//  AuthModule.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI

struct AuthModule: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator

    var body: some View {
        Group {
            AuthCoordinator(
                navigationPath: $appCoordinator.path,
                transitions: .init(authorized: {
                    appCoordinator.authCompleted()
                })
            ).view()
        }
    }
}

#Preview {
    AuthModule()
}
