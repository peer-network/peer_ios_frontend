//
//  APIService.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 03.04.25.
//

import Models
import GQLOperationsUser
import Foundation

public final class APIServiceStub: APIService {
    public init(){}
    
    //MARK: Auth/Reg
    public func fetchAuthorizedUserID() async -> Result<String, APIError> {
        .success("some ID")
    }
    
    public func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError> {
        .success(AuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN"))
    }
    
    public func registerUser(email: String, password: String, username: String) async -> Result<String, APIError> {
        .success("Registered")
    }
    
    public func verifyRegistration(userID: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    //MARK: User & Profile
    public func fetchUser(with userId: String) async -> Result<User, APIError> {
        .failure(.missingData)
    }
    
    public func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError> {
        .failure(.missingData)
    }
    
    public func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError> {
        .success(DailyFreeQuota(likes: 2, posts: 1, comments: 3))
    }
    
    public func followUser(with id: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    public func updateBio(new bio: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    public func uploadProfileImage(new image: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    //MARK: Posts
    public func fetchPostsByTitle(_ query: String, after offset: Int) async -> Result<[Post], APIError> {
        .failure(.missingData)
    }
    
    public func fetchPostsByTag(_ tag: String, after offset: Int) async -> Result<[Post], APIError> {
        .failure(.missingData)
    }
    
    public func makePost(of type: ContenType, with title: String, content: [String], contentDescitpion: String, tags: [String], cover: String?) async -> Result<Void, APIError> {
        .success(())
    }
    
    public func fetchPosts(with contentType: FeedContentType, sort byPopularity: FeedContentSortingByPopularity, filter byRelationship: FeedFilterByRelationship, in timeframe: FeedContentSortingByTime, after offset: Int, for userID: String?) async -> Result<[Post], APIError> {
        .failure(.missingData)
    }
    
    public func likePost(with id: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    public func dislikePost(with id: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    public func markPostViewed(with id: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    public func reportPost(with id: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    //MARK: Comments
    public func fetchComments(for postID: String, after offset: Int) async -> Result<[Comment], APIError> {
        .failure(.missingData)
    }
    
    public func sendComment(for postID: String, with content: String) async -> Result<Comment, APIError> {
        .failure(.missingData)
    }
    
    public func likeComment(with id: String) async -> Result<Void, APIError> {
        .success(())
    }
    
    //MARK: Tags
    public func fetchTags(with query: String) async -> Result<[String], APIError> {
        .success(["Tag1", "2gaT"])
    }
    
    //MARK: Wallet
    public func fetchLiquidityState() async -> Result<Double, APIError> {
        .success(1000.5)
    }
}
