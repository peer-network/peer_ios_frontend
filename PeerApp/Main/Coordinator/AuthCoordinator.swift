//
//  AuthCoordinator.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import SwiftUI
import Environment
import Models
import Auth

final class AuthCoordinator {
    struct Transitions {
        let authorized: () -> Void
    }
    
    @Binding var navigationPath: NavigationPath
    
    @Injected private var authManager: AuthManagerProtocol
    @Injected private var apiService: APIService
    private let id: UUID
    private let transitions: Transitions?
    
    init(navigationPath: Binding<NavigationPath>, transitions: Transitions? = nil) {
        self.id = UUID()
        self._navigationPath = navigationPath
        self.transitions = transitions
    }
    
    @MainActor @ViewBuilder
    func view() -> some View {
        let viewModel = AuthViewModel(authManager: authManager, apiService: apiService)
        MainAuthView(viewModel: viewModel)
    }
}

extension AuthCoordinator: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AuthCoordinator, rhs: AuthCoordinator) -> Bool {
        lhs.id == rhs.id
    }
}
