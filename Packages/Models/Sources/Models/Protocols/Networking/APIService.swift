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

    public var userFriendlyMessage: String {
        switch self {
            case .unknownError(let error):
                error.localizedDescription
            case .missingResponseCode:
                "An unexpected error from the server occurred"
            case .missingData:
                "Data from the server is missing"
            case .serverError(let code):
                ErrorCodeManager.shared.getUserFriendlyMessage(for: code)
        }
    }
}

public protocol APIService: AnyObject {
    //MARK: Auth/Reg
    func fetchAuthorizedUserID() async -> Result<String, APIError>
    func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError>
    func registerUser(email: String, password: String, username: String) async -> Result<String, APIError>
    func verifyRegistration(userID: String) async -> Result<Void, APIError>
    
    //MARK: User & Profile
    func fetchUser(with userId: String) async -> Result<User, APIError>
    func fetchUserFollowers(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUserFollowings(for userID: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError>
    func followUser(with id: String) async -> Result<Void, APIError>
    func updateBio(new bio: String) async -> Result<Void, APIError>
    func uploadProfileImage(new image: String) async -> Result<Void, APIError>
    
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
        for userID: String?
    ) async -> Result<[Post], APIError>
    func likePost(with id: String) async -> Result<Void, APIError>
    func dislikePost(with id: String) async -> Result<Void, APIError>
    func markPostViewed(with id: String) async -> Result<Void, APIError>
    func reportPost(with id: String) async -> Result<Void, APIError>
    
    //MARK: Comments
    func fetchComments(for postID: String, after offset: Int) async -> Result<[Comment], APIError>
    func sendComment(for postID: String, with content: String) async -> Result<Comment, APIError>
    func likeComment(with id: String) async -> Result<Void, APIError>
    
    //MARK: Tags
    func fetchTags(with query: String) async -> Result<[String], APIError>
    
    //MARK: Wallet
    func fetchLiquidityState() async -> Result<Double, APIError>
}
