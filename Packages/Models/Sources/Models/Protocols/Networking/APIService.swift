//
//  APIService.swift
//  Models
//
//  Created by Alexander Savchenko on 01.04.25.
//

import GQLOperationsUser

public enum APIError: Error {
    case serverError(error: Error)
    case missingData
}

public protocol APIService {
    //MARK: Auth/Reg
    func fetchAuthorizedUserID() async -> Result<String, APIError>
    func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError>
    func registerUser(email: String, password: String, username: String) async -> Result<String, APIError>
    func verifyRegistration(userID: String) async -> Result<Void, APIError>
    
    //MARK: User & Profile
    func fetchUser(with userId: String) async -> Result<User, APIError>
    func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError>
    func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError>
    func followUser(with id: String) async -> Result<Bool, APIError>
    func updateBio(new bio: String) async -> Result<Void, APIError>
    func uploadProfileImage(new image: String) async -> Result<Void, APIError>
    
    //MARK: Posts
    func fetchPosts(by query: String, after offset: Int) async -> Result<[Post], APIError>
    func fetchPosts(with tag: String, after offset: Int) async -> Result<[Post], APIError>
    func makePost(
        of type: ContenType,
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
