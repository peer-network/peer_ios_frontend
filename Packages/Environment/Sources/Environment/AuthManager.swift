//
//  AuthManager.swift
//  Environment
//
//  Created by Артем Васин on 31.01.25.
//

import SwiftUI
import TokenKeychainManager

@frozen
public enum AuthState {
    case loading
    case unauthenticated
    case authenticated(userId: String)
}

public protocol AuthManagerProtocol {
    func restoreSessionIfPossible() async -> AuthState
    func login(email: String, password: String) async throws
}

@MainActor
//TODO: Get rid of ObservableObject inheritance, bad practice to use @Published in service
public final class AuthManager: ObservableObject, AuthManagerProtocol {
    @Published public var state: AuthState = .loading
    
    private let accountManager: AccountManagerProtocol
    private let tokenManager: TokenKeychainManagerProtocol
    
    public nonisolated init(
        accountManager: AccountManagerProtocol = AccountManager.shared,
        tokenManager: TokenKeychainManagerProtocol = TokenKeychainManager.shared
    ) {
        self.accountManager = accountManager
        self.tokenManager = tokenManager
    }
    
    /// Checks if we have valid tokens and tries to fetch the current user ID.
    public func restoreSessionIfPossible() async -> AuthState {
        do {
            // If the token is valid, confirm it by calling "Hello" query
            let userId = try await accountManager.getCurrentUserId()

            // Optionally, fetch daily freebies or any user data
            try? await accountManager.fetchDailyFreeLimits()

            return .authenticated(userId: userId)
        } catch {
            // If the token call fails, user is unauthenticated
            return .unauthenticated
        }
    }
    
    /// Logs the user in, stores tokens, fetches current user ID.
    public func login(email: String, password: String) async throws {
        // Login and get tokens
        let token = try await accountManager.login(email: email, password: password)
        
        // Store tokens in Keychain
        tokenManager.setCredentials(accessToken: token.accessToken, refreshToken: token.refreshToken)
        
        // Query user ID (or decode from token if it includes userId claim)
        let userId = try await accountManager.getCurrentUserId()
        
        // Update state
        withAnimation {
            self.state = .authenticated(userId: userId)
        }

        // Fetch other user info if necessary
        try? await accountManager.fetchDailyFreeLimits()
    }
    
    /// Logs the user out, clears tokens, sets state to .unauthenticated
    public func logout() {
        tokenManager.removeCredentials()
        withAnimation {
            self.state = .unauthenticated
        }
    }
}
