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

@MainActor
public final class AuthManager: ObservableObject {
    @Published public private(set) var state: AuthState = .loading
    
    private let accountManager: AccountManager
    private let tokenManager: TokenKeychainManager
    
    public init(
        accountManager: AccountManager = .shared,
        tokenManager: TokenKeychainManager = .shared
    ) {
        self.accountManager = accountManager
        self.tokenManager = tokenManager
//        logout()
    }
    
    /// Checks if we have valid tokens and tries to fetch the current user ID.
    public func restoreSessionIfPossible() async {
        // If we have no tokens or they’re expired, user is unauthenticated
//        guard let _ = tokenManager.getAccessToken(),
//              !tokenManager.isAccessTokenExpired
//        else {
//            withAnimation {
//                self.state = .unauthenticated
//            }
//            return
//        }
//        
        do {
            // If the token is valid, confirm it by calling "Hello" query
            let userId = try await accountManager.getCurrentUserId()
            
            // We’re authenticated
            withAnimation {
                self.state = .authenticated(userId: userId)
            }

            // Optionally, fetch daily freebies or any user data
            try? await accountManager.fetchDailyFreeLimits()
            
        } catch {
            // If the token call fails, user is unauthenticated
            withAnimation {
                self.state = .unauthenticated
            }
        }
    }
    
    /// Logs the user in, stores tokens, fetches current user ID.
    public func login(email: String, password: String) async throws {
        // Login and get tokens
        let (accessToken, refreshToken) = try await accountManager.login(email: email, password: password)
        
        // Store tokens in Keychain
        tokenManager.setCredentials(accessToken: accessToken, refreshToken: refreshToken)
        
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
