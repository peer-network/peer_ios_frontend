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
    
    enum AuthenticationPage {
        case login, forgotPassword
    }
    
    @Binding var navigationPath: NavigationPath
    
    @Injected private var authManager: AuthManagerProtocol
    @Injected private var apiService: APIService
    private let id: UUID
    private var page: AuthenticationPage
    private let transitions: Transitions?
    
    init(navigationPath: Binding<NavigationPath>, page: AuthenticationPage = .login, transitions: Transitions? = nil) {
        self.id = UUID()
        self._navigationPath = navigationPath
        self.page = page
        self.transitions = transitions
    }
    
    @MainActor @ViewBuilder
    func view() -> some View {
        switch page {
        case .login:
            makeMainAuthView()
        case .forgotPassword:
            makeForgotPasswordView()
        }
    }
    
    @MainActor
    private func makeMainAuthView() -> some View {
        let viewModel = AuthViewModel(
            authManager: authManager,
            apiService: apiService,
            transitions: AuthViewModel.Transitions(
                authorized: self.authorizedSuccessful,
                forgotPassword: self.startForgotPassword
            )
        )
        return MainAuthView(viewModel: viewModel)
    }
    
    @MainActor
    private func makeForgotPasswordView() -> some View {
        return EmptyView()
    }
    
    private func authorizedSuccessful() {
        self.transitions?.authorized()
    }
    
    private func startForgotPassword() {
        self.push(AuthCoordinator(navigationPath: self.$navigationPath, page: .forgotPassword))
    }
    
    private func push<V>(_ value: V) where V : Hashable {
        navigationPath.append(value)
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
