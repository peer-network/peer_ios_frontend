//
//  APIServiceGraphQL.swift
//  Networking
//
//  Created by Alexander Savchenko on 01.04.25.
//

import Models
import GQLOperationsUser
import GQLOperationsGuest
import Foundation

public final class APIServiceGraphQL: APIService {
    let qlClient: GQLClient
    
    public init(qlClient: GQLClient = GQLClient.shared) {
        self.qlClient = qlClient
    }
    
    //MARK: Auth/Reg
    public func fetchAuthorizedUserID() async -> Result<String, APIError> {
        do {
            let result = try await qlClient.fetch(query: HelloUserQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            guard let userId = result.hello.currentuserid, !userId.isEmpty else {
                return .failure(.missingData)
            }
            
            return .success(userId)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: LoginMutation(email: email, password: password))
            
            guard let accessToken = result.login.accessToken,
                  let refreshToken = result.login.refreshToken
            else {
                return .failure(.missingData)
            }
            
            return .success(AuthToken(accessToken: accessToken, refreshToken: refreshToken))
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func registerUser(email: String, password: String, username: String) async -> Result<String, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: RegisterMutation(email: email, password: password, username: username))
            
            guard result.isSuccessStatus,
                  let userID = result.register.userid
            else {
                return .failure(.missingData)
            }
            
            return .success(userID)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func verifyRegistration(userID: String) async -> Result<Void, APIError> {
        do {
            let _ = try await qlClient.mutate(mutation: VerificationMutation(userid: userID))
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    //MARK: User & Profile
    public func fetchUser(with userId: String) async -> Result<User, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetProfileQuery(userid: userId), cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard
                let data = result.profile.affectedRows,
                let fetchedUser = User(gqlUser: data)
            else {
                return .failure(.missingData)
            }
            
            return .success(fetchedUser)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func fetchUserFollowers(for userID: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let operation = GetFollowersQuery(
                userid: GraphQLNullable(stringLiteral: userID),
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )
            
            let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.follows.affectedRows?.followers else {
                throw GQLError.missingData
            }
            
            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }
            
            return .success(fetchedUsers)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func fetchUserFollowings(for userID: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let operation = GetFollowingsQuery(
                userid: GraphQLNullable(stringLiteral: userID),
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )
            
            let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.follows.affectedRows?.following else {
                throw GQLError.missingData
            }
            
            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }
            
            return .success(fetchedUsers)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let operation = SearchUserQuery(
                userid: nil,
                username: GraphQLNullable(stringLiteral: query.lowercased()),
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.searchuser.affectedRows else {
                throw GQLError.missingData
            }
            
            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }
            
            return .success(fetchedUsers)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetDailyFreeQuery())
            
            guard let dataArray = result.dailyfreestatus.affectedRows else {
                return .failure(.missingData)
            }
            
            var likes: Int = 0, comments: Int = 0, posts: Int = 0
            for case let row? in dataArray {
                switch row.name {
                case "Likes":
                    likes = row.available
                case "Comments":
                    comments = row.available
                case "Posts":
                    posts = row.available
                default:
                    break
                }
            }
            
            return .success(DailyFreeQuota(likes: likes, posts: posts, comments: comments))
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func followUser(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: FollowUserMutation(userid: id))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func updateBio(new bio: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdateBioMutation(biography: bio))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func uploadProfileImage(new image: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdateAvatarMutation(img: image))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    
    //MARK: Posts
    public func fetchPostsByTitle(_ query: String, after offset: Int) async -> Result<[Post], APIError> {
        do {
            let operation = GetAllPostsQuery(
                filterBy: [.case(.image), .case(.text), .case(.video), .case(.audio)],
                ignorList: .some(.case(.no)),
                sortBy: .some(.case(.newest)),
                title: GraphQLNullable(stringLiteral: query.lowercased()),
                tag: nil,
                from: nil,
                to: nil,
                postOffset: GraphQLNullable<Int>(integerLiteral: offset),
                postLimit: 20,
                commentOffset: nil,
                commentLimit: nil,
                postid: nil,
                userid: nil
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.getallposts.affectedRows else {
                return .failure(APIError.missingData)
            }
            
            let fetchedPosts = data.compactMap { value in
                Post(gqlPost: value)
            }
            
            return .success(fetchedPosts)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func fetchPostsByTag(_ tag: String, after offset: Int) async -> Result<[Post], APIError> {
        do {
            let operation = GetAllPostsQuery(
                filterBy: [.case(.image), .case(.text), .case(.video), .case(.audio)],
                ignorList: .some(.case(.no)),
                sortBy: .some(.case(.newest)),
                title: nil,
                tag: GraphQLNullable(stringLiteral: tag.lowercased()),
                from: nil,
                to: nil,
                postOffset: GraphQLNullable<Int>(integerLiteral: offset),
                postLimit: 20,
                commentOffset: nil,
                commentLimit: nil,
                postid: nil,
                userid: nil
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.getallposts.affectedRows else {
                return .failure(APIError.missingData)
            }
            
            let fetchedPosts = data.compactMap { value in
                Post(gqlPost: value)
            }
            
            return .success(fetchedPosts)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func makePost(
        of type: ContenType,
        with title: String,
        content: [String],
        contentDescitpion: String,
        tags: [String],
        cover: String?
    ) async -> Result<Void, APIError> {
        do {
            var coverString: GraphQLNullable<[String]> = nil
            if let cover, !cover.isEmpty {
                coverString = GraphQLNullable<[String]>.some([cover])
            }
            
            let operation = CreatePostMutation(
                contenttype: .case(type),
                title: title,
                media: GraphQLNullable<[String]>.some(content),
                mediadescription: GraphQLNullable(stringLiteral: contentDescitpion),
                tags: GraphQLNullable<[String]>.some(tags),
                cover: coverString
            )
            
            let result = try await qlClient.mutate(mutation: operation)
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func fetchPosts(
        with contentType: FeedContentType,
        sort byPopularity: FeedContentSortingByPopularity,
        filter byRelationship: FeedFilterByRelationship,
        in timeframe: FeedContentSortingByTime,
        after offset: Int,
        for userID: String?
    ) async -> Result<[Post], APIError> {
        let sortBy = byPopularity.apiValue

        var filterBy: [GraphQLEnum<FilterType>] = contentType.apiValue
        if let filterByAddition = byRelationship.apiValue {
            filterBy.append(filterByAddition)
        }

        let timeFrom = timeframe.apiValue.0
        let timeTo = timeframe.apiValue.1

        let operation = GetAllPostsQuery(
            filterBy: GraphQLNullable<[GraphQLEnum<FilterType>]>.some(filterBy),
            ignorList: .some(.case(.yes)),
            sortBy: sortBy,
            title: nil,
            tag: nil,
            from: timeFrom != nil ? GraphQLNullable(stringLiteral: timeFrom!) : nil,
            to: timeTo != nil ? GraphQLNullable(stringLiteral: timeTo!) : nil,
            postOffset: GraphQLNullable<Int>(integerLiteral: offset),
            postLimit: GraphQLNullable<Int>(integerLiteral: 10),
            commentOffset: 0,
            commentLimit: 0,
            postid: nil,
            userid: userID == nil ? nil : GraphQLNullable(stringLiteral: userID!)
        )

        do {
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.getallposts.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedPosts = data.compactMap { value in
                Post(gqlPost: value)
            }
            
            return .success(fetchedPosts)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func likePost(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.like)))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func dislikePost(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.dislike)))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func markPostViewed(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.view)))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func reportPost(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.report)))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    //MARK: Comments
    public func fetchComments(for postID: String, after offset: Int) async -> Result<[Comment], APIError> {
        do {
            let operation =  GetPostCommentsQuery(
                postid: postID,
                commentLimit: GraphQLNullable<Int>(integerLiteral: 20),
                commentOffset: GraphQLNullable<Int>(integerLiteral: offset)
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.getallposts.affectedRows?.first?.comments else {
                return .failure(.missingData)
            }
            
            let fetchedComments = data.compactMap { value in
                Comment(gqlComment: value)
            }
            
            return .success(fetchedComments)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func sendComment(for postID: String, with content: String) async -> Result<Comment, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: CreateCommentMutation(postid: postID, parentid: nil, content: content))
            
            guard let data = result.createComment.affectedRows?.first,
                  case let .some(commentData) = data,
                  let comment = Comment(gqlComment: commentData)
            else {
                return .failure(.missingData)
            }
            
            return .success(comment)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    public func likeComment(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: LikeCommentMutation(commentid: id))
            
            guard result.isSuccessStatus else {
                return .failure(.missingData)
            }
            
            return .success(())
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    //MARK: Tags
    public func fetchTags(with query: String) async -> Result<[String], APIError> {
        do {
            let operation = SearchTagsQuery(tagname: query, offset: 0, limit: 20)
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.tagsearch.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedTags = data
                .compactMap{ $0 }
                .map{ $0.name }
            
            return .success(fetchedTags)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
    
    //MARK: Wallet
    public func fetchLiquidityState() async -> Result<Double, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetLiquidityQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            
            guard let data = result.currentliquidity.currentliquidity,
                  let amount = Double(data)
            else {
                return .failure(.missingData)
            }
            
            return .success(amount)
        } catch {
            return .failure(.serverError(error: error))
        }
    }
}
