//
//  APIService.swift
//  Models
//
//  Created by Alexander Savchenko on 01.04.25.
//

import GQLOperationsUser
import Foundation

public enum APIError: Error, LocalizedError {
    case unknownError(error: Error)
    case missingResponseCode(meta: APIResponseMeta? = nil)
    case missingData
    case serverError(meta: APIResponseMeta)

    /// Backwards-compatible helper so old call sites like `.serverError(code: ...)` still compile
    public static func serverError(
        code: String,
        message: String? = nil,
        requestId: String? = nil,
        status: String? = nil
    ) -> APIError {
        .serverError(meta: APIResponseMeta(
            status: status,
            responseCode: code,
            responseMessage: message,
            requestId: requestId
        ))
    }

    // MARK: - Convenience accessors

    public var meta: APIResponseMeta? {
        switch self {
            case .serverError(let meta): return meta
            case .missingResponseCode(let meta): return meta
            default: return nil
        }
    }

    public var errorDescription: String? { userFriendlyMessage } // LocalizedError

    public var userFriendlyMessage: String {
        switch self {
            case .unknownError(let error):
                // If the underlying error is already an APIError, it'll use *its* user message
                return (error as? LocalizedError)?.errorDescription ?? error.localizedDescription

            case .missingResponseCode(let meta):
                return APIError.composeUserMessage(
                    base: "An unexpected error from the server occurred",
                    requestId: meta?.requestId
                )

            case .missingData:
                return "Data from the server is missing"

            case .serverError(let meta):
                let base: String = {
                    if let msg = meta.responseMessage?.trimmingCharacters(in: .whitespacesAndNewlines),
                       !msg.isEmpty {
                        return msg
                    }
                    if let code = meta.responseCode {
                        return ErrorCodeManager.shared.getUserFriendlyMessage(for: code)
                    }
                    return "An unexpected error from the server occurred"
                }()

                return APIError.composeUserMessage(base: base, requestId: meta.requestId)
        }
    }

    private static func composeUserMessage(base: String, requestId: String?) -> String {
        guard let id = requestId?.trimmingCharacters(in: .whitespacesAndNewlines), !id.isEmpty else {
            return base
        }
        return "\(base) (Request ID: \(id))"
    }
}

public extension Error {
    var userFriendlyDescription: String {
        // If it’s APIError, use the message above; otherwise fall back to localizedDescription
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }
}

public protocol APIService: AnyObject {
    //MARK: Auth/Reg
    func fetchAuthorizedUserID() async -> Result<String, APIError>
    func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError>
    func verifyReferralCode(code: String) async -> Result<Void, APIError>
    func registerUser(email: String, password: String, username: String, referralUuid: String) async -> Result<String, APIError>
    func verifyRegistration(userID: String) async -> Result<Void, APIError>
    func requestPasswordReset(email: String) async -> Result<Void, APIError>
    func verifyResetPasswordCode(code: String) async -> Result<Void, APIError>
    func resetPassword(token: String, newPassword: String) async -> Result<Void, APIError>
    func deleteAccount(password: String) async -> Result<Void, APIError>

    //MARK: User & Profile
    func getMyInviter() async -> Result<RowUser?, APIError>
    func getMyReferralInfo() async -> Result<ReferralInfo, APIError>
    func getMyReferredUsers(after offset: Int) async -> Result<[RowUser], APIError>
    func getMyUserInfo() async -> Result<(contentFilter: OffensiveContentFilter, shownOnboardings: [Onboarding]), APIError>
    func updateShownOnboardings(_ onboarding: Onboarding) async -> Result<Void, APIError>
    func fetchUser(with userId: String) async -> Result<User, APIError>
    func fetchUserFollowers(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUserFollowings(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUserFriends(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError>
    func followUser(with id: String) async -> Result<Void, APIError>
    func updateBio(new bio: String) async -> Result<Void, APIError>
    func uploadProfileImage(new image: String) async -> Result<Void, APIError>
    func updateUsername(username: String, currentPassword: String) async -> Result<Void, APIError>
    func updatePassword(password: String, currentPassword: String) async -> Result<Void, APIError>
    func updateEmail(email: String, currentPassword: String) async -> Result<Void, APIError>
    func toggleHideUserContent(with id: String) async -> Result<Bool, APIError>
    func fetchUsersWithHiddenContent(after offset: Int) async -> Result<[RowUser], APIError>
    func reportUser(with id: String) async -> Result<Void, APIError>

    //MARK: Posts
    func fetchPostById(_ id: String) async -> Result<Post, APIError>
    func fetchPostsByTitle(_ query: String, after offset: Int) async -> Result<[Post], APIError>
    func fetchPostsByTag(_ tag: String, after offset: Int) async -> Result<[Post], APIError>
    func getMediaUploadToken() async -> Result<String, APIError>
    func makePost(
        of type: ContentType,
        with title: String,
        content: [String],
        contentDescitpion: String,
        tags: [String],
        cover: String?
    ) async -> Result<Void, APIError>
    func makePostMultipart(
        of type: ContentType,
        with title: String,
        content: String,
        contentDescitpion: String,
        tags: [String],
        cover: String?
    ) async -> Result<Void, APIError>
    func fetchPosts(
        with contentType: FeedContentType,
        sort byPopularity: FeedContentSortingByPopularity,
        showHiddenContent: Bool,
        filter byRelationship: FeedFilterByRelationship,
        in timeframe: FeedContentSortingByTime,
        after offset: Int,
        for userID: String?,
        amount: Int
    ) async -> Result<[Post], APIError>
    func likePost(with id: String) async -> Result<Void, APIError>
    func dislikePost(with id: String) async -> Result<Void, APIError>
    func markPostViewed(with id: String) async -> Result<Void, APIError>
    func reportPost(with id: String) async -> Result<Void, APIError>
    func getPostInteractions(with id: String, type: PostInteraction, after offset: Int) async -> Result<[RowUser], APIError>

    //MARK: Comments
    func fetchComments(for postID: String, after offset: Int) async -> Result<[Comment], APIError>
    func sendComment(for postID: String, with content: String) async -> Result<Comment, APIError>
    func likeComment(with id: String) async -> Result<Void, APIError>
    func reportComment(with id: String) async -> Result<Void, APIError>
    func getCommentInteractions(with id: String, after offset: Int) async -> Result<[RowUser], APIError>

    //MARK: Tags
    func fetchTags(with query: String) async -> Result<[String], APIError>

    //MARK: Wallet
    func fetchLiquidityState() async -> Result<Decimal, APIError>
    func transferTokens(to id: String, amount: Foundation.Decimal, message: String?) async -> Result<Void, APIError>
    func fetchTransactionsHistory(after offset: Int) async -> Result<[Models.Transaction], APIError>

    // MARK: Ads
    func getListOfAds(userID: String?, with contentType: PostContentType, after offset: Int, amount: Int) async -> Result<[Post], APIError>
    func getAdsHistoryList(userID: String, after offset: Int, amount: Int) async -> Result<[SingleAdStats], APIError>
    func getAdsHistoryStats(userID: String) async -> Result<AdsStats, APIError>
    func promotePostPinned(for postID: String) async -> Result<String, APIError>

    // MARK: Shop
    func performShopOrder(deliveryData: DeliveryData, price: Foundation.Decimal, itemId: String, size: String?) async -> Result<Void, APIError>
    func getShopOrderDetails(transactionId: String) async -> Result<ShopOrder, APIError>
}
