//
//  APIService.swift
//  Models
//
//  Created by Alexander Savchenko on 01.04.25.
//

import GQLOperationsUser

public enum APIError: Error {
    case unknownError(error: Error)
    case missingResponseCode // Server did not return any response code
    case missingData // Server returns success, but since most of the fields are optional, they can be missed
    case serverError(code: String)
    case streamError(error: Error)

    public var userFriendlyMessage: String {
        switch self {
            case .unknownError(let error):
                error.userFriendlyDescription
            case .missingResponseCode:
                "An unexpected error from the server occurred"
            case .missingData:
                "Data from the server is missing"
            case .serverError(let code):
                ErrorCodeManager.shared.getUserFriendlyMessage(for: code)
            case .streamError:                  // 👈 NEW
                   "Lost connection to the live-chat service. Retrying…"
        }
    }
}

public protocol APIService: AnyObject {
    //MARK: Auth/Reg
    func fetchAuthorizedUserID() async -> Result<String, APIError>
    func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError>
    func registerUser(email: String, password: String, username: String, referralUuid: String?) async -> Result<String, APIError>
    func verifyRegistration(userID: String) async -> Result<Void, APIError>
    func requestPasswordReset(email: String) async -> Result<Void, APIError>
    func resetPassword(token: String, newPassword: String) async -> Result<Void, APIError>

    //MARK: User & Profile
    func getMyInviter() async -> Result<RowUser, APIError>
    func getMyReferralInfo() async -> Result<ReferralInfo, APIError>
    func getMyReferredUsers(after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUser(with userId: String) async -> Result<User, APIError>
    func fetchUserFollowers(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUserFollowings(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUserFriends(after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError>
    func followUser(with id: String) async -> Result<Void, APIError>
    func updateBio(new bio: String) async -> Result<Void, APIError>
    func uploadProfileImage(new image: String) async -> Result<Void, APIError>
    func updateUsername(username: String, currentPassword: String) async -> Result<Void, APIError>
    func updatePassword(password: String, currentPassword: String) async -> Result<Void, APIError>
    func updateEmail(email: String, currentPassword: String) async -> Result<Void, APIError>

    //MARK: Posts
    func fetchPostsByTitle(_ query: String, after offset: Int) async -> Result<[Post], APIError>
    func fetchPostsByTag(_ tag: String, after offset: Int) async -> Result<[Post], APIError>
    func makePost(
        of type: ContentType,
        with title: String,
        content: [String],
        contentDescitpion: String,
        tags: [String],
        cover: String?
    ) async -> Result<Void, APIError>
    func fetchPosts(
        with contentType: FeedContentType,
        sort byPopularity: FeedContentSortingByPopularity,
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
    
    //MARK: Comments
    func fetchComments(for postID: String, after offset: Int) async -> Result<[Comment], APIError>
    func sendComment(for postID: String, with content: String) async -> Result<Comment, APIError>
    func likeComment(with id: String) async -> Result<Void, APIError>
    
    //MARK: Chats
    func sendChatMessage(with chatid: ID, content: String) async -> Result<Void, APIError>
//    func listChatMessages(with chatid: ID) async -> Result<ListChatMessagesQuery.Data, APIError>
    func listChatMessages(for chatid: GQLOperationsUser.ID) async -> Result<ListChatMessages, APIError>
    func listChats() async -> Result<[Models.ListChats], APIError>
    func subscribeToChatMessages(chatId: GQLOperationsUser.ID) -> AsyncThrowingStream<GetChatMessagesSubscription.Data, Error>
    func addChatParticipants(chatId: GQLOperationsUser.ID, recipients: [String]) async -> Result<Void, APIError>
    func createChat(name: String, recipients: [String], image: String?) async -> Result<String, APIError>
    
    //MARK: Tags
    func fetchTags(with query: String) async -> Result<[String], APIError>
    
    //MARK: Wallet
    func fetchLiquidityState() async -> Result<Double, APIError>
    func transferTokens(to id: String, amount: Int) async -> Result<Void, APIError>
}
