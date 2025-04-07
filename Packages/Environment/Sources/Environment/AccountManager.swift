//
//  AccountManager.swift
//  Environment
//
//  Created by Артем Васин on 23.12.24.
//

import SwiftUI
import Models
import TokenKeychainManager

@MainActor
public final class AccountManager: ObservableObject {
    public static let shared = AccountManager()

    @Published public private(set) var dailyFreeLikes: Int = 0
    @Published public private(set) var dailyFreeComments: Int = 0
    @Published public private(set) var dailyFreePosts: Int = 0

    public private(set) var userId: String?
    public private(set) var user: User?
    
    private let apiService: APIService

    private init() {
        apiService = APIServiceManager().apiService
    }

    public func login(email: String, password: String) async throws -> AuthToken {
        let result = await apiService.loginWithCredentials(email: email, password: password)
        
        switch result {
        case .success(let token):
            return token
        case .failure(let apiError):
            throw apiError
        }
    }

    /// Hello query to confirm the user’s ID with the valid access token
    public func getCurrentUserId() async throws -> String {
        let result = await apiService.fetchAuthorizedUserID()
        
        switch result {
        case .success(let userID):
            self.userId = userID
            try? await fetchUser(userId: userID)
            
            return userID
        case .failure(let apiError):
            throw apiError
        }
    }

    private func fetchUser(userId: String) async throws {
        let result = await apiService.fetchUser(with: userId)
        
        switch result {
        case .success(let user):
            self.user = user
        case .failure(let apiError):
            throw apiError
        }
    }

    public func fetchDailyFreeLimits() async throws {
        let result = await apiService.fetchDailyFreeLimits()
        
        switch result {
        case .success(let quotas):
            dailyFreeLikes = quotas.likes
            dailyFreePosts = quotas.posts
            dailyFreeComments = quotas.comments
        case .failure(_):
            dailyFreeLikes = 0
            dailyFreePosts = 0
            dailyFreeComments = 0
        }
    }

    public func freeLikeUsed() {
        dailyFreeLikes -= 1
    }

    public func freeCommentUsed() {
        dailyFreeComments -= 1
    }

    public func freePostUsed() {
        dailyFreePosts -= 1
    }

    public func increaseFreeLikes() {
        dailyFreeLikes += 1
    }

    public func increaseFreeComments() {
        dailyFreeComments += 1
    }

    public func increaseFreePosts() {
        dailyFreePosts += 1
    }

    public func isCurrentUser(id: String) -> Bool {
        id == userId
    }
}
