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

    public func verifyReferralCode(code: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func registerUser(email: String, password: String, username: String, referralUuid: String) async -> Result<String, APIError> {
        .success("Registered")
    }
    
    public func verifyRegistration(userID: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func requestPasswordReset(email: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func verifyResetPasswordCode(code: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func resetPassword(token: String, newPassword password: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func deleteAccount(password: String) async -> Result<Void, APIError> {
        .success(())
    }

    //MARK: User & Profile
    public func getMyInviter() async -> Result<RowUser?, APIError> {
        .failure(.missingData)
    }

    public func getMyReferralInfo() async -> Result<ReferralInfo, APIError> {
        .failure(.missingData)
    }

    public func getMyReferredUsers(after offset: Int) async -> Result<[RowUser], APIError> {
        .failure(.missingData)
    }

    public func getMyUserInfo() async -> Result<(contentFilter: OffensiveContentFilter, shownOnboardings: [Onboarding]), APIError> {
        .failure(.missingData)
    }

    public func updateShownOnboardings(_ onboarding: Onboarding) async -> Result<Void, APIError> {
        .success(())
    }

    public func fetchUser(with userId: String) async -> Result<User, APIError> {
        .failure(.missingData)
    }
    
    public func fetchUserFollowers(for userID: String, after offset: Int) async -> Result<[Models.RowUser], Models.APIError> {
        .failure(.missingData)
    }
    
    public func fetchUserFollowings(for userID: String, after offset: Int) async -> Result<[Models.RowUser], Models.APIError> {
        .failure(.missingData)
    }

    public func fetchUserFriends(after offset: Int) async -> Result<[RowUser], APIError> {
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

    public func updateUsername(username: String, currentPassword: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func updatePassword(password: String, currentPassword: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func updateEmail(email: String, currentPassword: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func toggleHideUserContent(with id: String) async -> Result<Bool, APIError> {
        .success(true)
    }

    public func fetchUsersWithHiddenContent(after offset: Int) async -> Result<[RowUser], APIError> {
        .failure(.missingData)
    }

    public func reportUser(with id: String) async -> Result<Void, APIError> {
        .success(())
    }

    //MARK: Posts
    public func fetchPostById(_ id: String) async -> Result<Post, APIError> {
        .failure(.missingData)
    }

    public func fetchPostsByTitle(_ query: String, after offset: Int) async -> Result<[Post], APIError> {
        .failure(.missingData)
    }
    
    public func fetchPostsByTag(_ tag: String, after offset: Int) async -> Result<[Post], APIError> {
        .failure(.missingData)
    }

    public func getMediaUploadToken() async -> Result<String, APIError> {
        .success("123")
    }

    public func makePost(of type: ContentType, with title: String, content: [String], contentDescitpion: String, tags: [String], cover: String?) async -> Result<Void, APIError> {
        .success(())
    }

    public func makePostMultipart(of type: ContentType, with title: String, content: String, contentDescitpion: String, tags: [String], cover: String?) async -> Result<Void, APIError> {
        .success(())
    }

    public func fetchPosts(with contentType: FeedContentType, sort byPopularity: FeedContentSortingByPopularity, showHiddenContent: Bool, filter byRelationship: FeedFilterByRelationship, in timeframe: FeedContentSortingByTime, after offset: Int, for userID: String?, amount: Int) async -> Result<[Post], APIError> {
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

    public func getPostInteractions(with id: String, type: PostInteraction, after offset: Int) async -> Result<[RowUser], APIError> {
        .failure(.missingData)
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

    public func reportComment(with id: String) async -> Result<Void, APIError> {
        .success(())
    }

    public func getCommentInteractions(with id: String, after offset: Int) async -> Result<[RowUser], APIError> {
        .failure(.missingData)
    }

    //MARK: Tags
    public func fetchTags(with query: String) async -> Result<[String], APIError> {
        .success(["Tag1", "2gaT"])
    }
    
    //MARK: Wallet
    public func fetchLiquidityState() async -> Result<Decimal, APIError> {
        .success(1000.5)
    }

    public func transferTokens(to id: String, amount: Double, message: String?) async -> Result<Void, APIError> {
        .success(())
    }

    public func fetchTransactionsHistory(after offset: Int) async -> Result<[Transaction], APIError> {
        .failure(.missingData)
    }

    //MARK: Advertisements
    public func getListOfAds(userID: String?, with contentType: PostContentType, after offset: Int, amount: Int) async -> Result<[Post], APIError> {
        .failure(.missingData)
    }

    public func getAdsHistoryList(userID: String, after offset: Int, amount: Int) async -> Result<[SingleAdStats], APIError> {
        .failure(.missingData)
    }

    public func getAdsHistoryStats(userID: String) async -> Result<AdsStats, APIError> {
        .failure(.missingData)
    }

    public func promotePostPinned(for postID: String) async -> Result<String, APIError> {
        .failure(.missingData)
    }
}
