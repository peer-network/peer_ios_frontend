//
//  AuthModule.swift
//  PeerApp
//
//  Created by Artem Vasin on 23.05.25.
//

//import SwiftUI
//
//struct AuthModule: View {
//    @EnvironmentObject private var appCoordinator: AppCoordinator
//
//    var body: some View {
//        Group {
//            NavigationStack(path: $appCoordinator.path) {
//                AuthCoordinator(
//                    navigationPath: $appCoordinator.path,
//                    transitions: .init(authorized: {
//                        appCoordinator.authCompleted()
//                    })
//                ).view()
//                    .navigationDestination(for: AuthCoordinator.self) { coordinator in
//                        coordinator.view()
//                    }
//            }
//        }
//    }
//}
//
//#Preview {
//    AuthModule()
//}
