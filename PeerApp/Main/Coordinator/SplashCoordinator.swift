//
//  SplashCoordinator.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import Foundation
import SwiftUI
import Environment

final class SplashCoordinator {
    struct Transitions {
        let initCompleted: (_ restored: Bool) -> Void
    }
    
    @Binding var navigationPath: NavigationPath
    
    @Injected private var authManager: AuthManagerProtocol
    private let id: UUID
    private let transitions: Transitions?
    
    init(navigationPath: Binding<NavigationPath>, transitions: Transitions? = nil) {
        id = UUID()
        self.transitions = transitions
        self._navigationPath = navigationPath
    }
    
    @MainActor @ViewBuilder
    func view() -> some View {
        let viewModel = SplashViewModel(authManager: authManager, transitions: .init(initCompleted: { restored in
            self.transitions?.initCompleted(restored)
        }))
        SplashView(viewModel: viewModel)
    }
}

extension SplashCoordinator: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SplashCoordinator, rhs: SplashCoordinator) -> Bool {
        lhs.id == rhs.id
    }
}
