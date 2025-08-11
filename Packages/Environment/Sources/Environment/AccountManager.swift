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
    public static var shared: AccountManager {
        if let instance = _shared {
            return instance
        }
        let instance = AccountManager()
        _shared = instance
        return instance
    }
    private static var _shared: AccountManager?

    @Published public private(set) var dailyFreeLikes: Int = 0
    @Published public private(set) var dailyFreeComments: Int = 0
    @Published public private(set) var dailyFreePosts: Int = 0

    public private(set) var userId: String?
    public private(set) var user: User?
    public private(set) var inviter: RowUser?
    @AppStorage("offensiveContentFilter", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var offensiveContentFilter: OffensiveContentFilter = .blocked

    private var apiService: APIService
    private var currentConfiguration: APIConfiguration
    
    private init() {
        // Default to production configuration
        self.currentConfiguration = APIConfiguration(endpoint: .production)
        self.apiService = APIServiceManager(.normal(config: currentConfiguration)).apiService
    }

    public static func configure(with config: APIConfiguration) {
        if _shared != nil {
            // If shared instance already exists, we need to recreate it with new configuration
            _shared = AccountManager(config: config)
        } else {
            // Store configuration for future use
            _shared?.currentConfiguration = config
        }
    }

    private init(config: APIConfiguration) {
        self.currentConfiguration = config
        self.apiService = APIServiceManager(.normal(config: config)).apiService
    }

    public func updateConfiguration(_ config: APIConfiguration) {
        self.currentConfiguration = config
        // Recreate the API service with new configuration
        let newAPIService = APIServiceManager(.normal(config: config)).apiService
        // Since AccountManager is a class, we can update the reference
        self.apiService = newAPIService
    }

    public func login(email: String, password: String) async throws(APIError) -> AuthToken {
        let result = await apiService.loginWithCredentials(email: email, password: password)

        switch result {
            case .success(let token):
                return token
            case .failure(let apiError):
                throw apiError
        }
    }

    /// Hello query to confirm the user’s ID with the valid access token
    public func getCurrentUserId() async throws(APIError) -> String {
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

    public func fetchUserInviter() async throws {
        let result = await apiService.getMyInviter()

        switch result {
            case .success(let inviter):
                self.inviter = inviter
            case .failure(let apiError):
                self.inviter = nil
                throw apiError
        }
    }

    public func fetchUserInfo() async throws {
        let result = await apiService.getMyUserInfo()

        switch result {
            case .success(let filter):
                self.offensiveContentFilter = filter
            case .failure(let apiError):
                throw apiError
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
