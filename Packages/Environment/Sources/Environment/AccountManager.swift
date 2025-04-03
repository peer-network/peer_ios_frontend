//
//  AccountManager.swift
//  Environment
//
//  Created by Артем Васин on 23.12.24.
//

import SwiftUI
import Networking
import Models
import GQLOperationsUser
import GQLOperationsGuest
import TokenKeychainManager

@MainActor
public final class AccountManager: ObservableObject {
    public static let shared = AccountManager()

    @Published public private(set) var dailyFreeLikes: Int = 0
    @Published public private(set) var dailyFreeComments: Int = 0
    @Published public private(set) var dailyFreePosts: Int = 0

    public private(set) var userId: String?
    public private(set) var user: User?
    
    private let service: APIService

    private init() {
        service = APIServiceGraphQL()
    }

    public func login(email: String, password: String) async throws -> (String, String) {
        let result = try await GQLClient.shared.mutate(mutation: LoginMutation(email: email, password: password))

        guard
            let accessToken = result.login.accessToken,
            let refreshToken = result.login.refreshToken
        else {
            throw GQLError.missingData
        }

        return (accessToken, refreshToken)
    }

    /// Hello query to confirm the user’s ID with the valid access token
    public func getCurrentUserId() async throws -> String {
        let result = try await GQLClient.shared.fetch(query: HelloUserQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
        let result1 = await service.fetchAuthorizedUserID()
        guard let userId = result.hello.currentuserid, !userId.isEmpty else {
            throw GQLError.missingData
        }
        self.userId = userId
        try? await fetchUser(userId: userId)
        return userId
    }

    private func fetchUser(userId: String) async throws {
        let result = try await GQLClient.shared.fetch(query: GetProfileQuery(userid: userId), cachePolicy: .fetchIgnoringCacheCompletely)

        guard
            let data = result.profile.affectedRows,
            let fetchedUser = User(gqlUser: data)
        else {
            throw GQLError.missingData
        }

        user = fetchedUser
    }

    public func fetchDailyFreeLimits() async throws {
        let result = try await GQLClient.shared.fetch(query: GetDailyFreeQuery())

        if
            let likesRow = result.dailyfreestatus.affectedRows?.first(where: { row in
                row?.name == "Likes"
            }),
            let likes = likesRow?.available
        {
            dailyFreeLikes = likes
        } else {
            dailyFreeLikes = 0
        }

        if
            let commentsRow = result.dailyfreestatus.affectedRows?.first(where: { row in
                row?.name == "Comments"
            }),
            let comments = commentsRow?.available
        {
            dailyFreeComments = comments
        } else {
            dailyFreeComments = 0
        }

        if
            let postsRow = result.dailyfreestatus.affectedRows?.first(where: { row in
                row?.name == "Posts"
            }),
            let posts = postsRow?.available
        {
            dailyFreePosts = posts
        } else {
            dailyFreePosts = 0
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
