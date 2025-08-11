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
            return .failure(.unknownError(error: error))
        }
    }
    
    public func loginWithCredentials(email: String, password: String) async -> Result<AuthToken, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: LoginMutation(email: email, password: password))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let accessToken = result.login.accessToken,
                  let refreshToken = result.login.refreshToken
            else {
                return .failure(.missingData)
            }
            
            return .success(AuthToken(accessToken: accessToken, refreshToken: refreshToken))
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func registerUser(email: String, password: String, username: String, referralUuid: String) async -> Result<String, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: RegisterMutation(email: email, password: password, username: username, referralUuid: referralUuid))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard
                let userID = result.register.userid
            else {
                return .failure(.missingData)
            }
            
            return .success(userID)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func verifyRegistration(userID: String) async -> Result<Void, APIError> {
        do {
            let _ = try await qlClient.mutate(mutation: VerificationMutation(userid: userID))
            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func requestPasswordReset(email: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: RequestPasswordResetMutation(email: email))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func resetPassword(token: String, newPassword: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: ConfirmPasswordResetMutation(token: token, password: newPassword))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func deleteAccount(password: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: DeleteAccountMutation(password: password))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    //MARK: User & Profile
    public func getMyInviter() async -> Result<RowUser, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetMyInviterQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard
                let data = result.referralList.affectedRows.invitedBy,
                !data.id.isEmpty,
                let inviter = RowUser(gqlUser: data)
            else {
                return .failure(.missingData)
            }

            return .success(inviter)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func getMyReferralInfo() async -> Result<ReferralInfo, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetMyReferralInfoQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard
                let referralInfo = ReferralInfo(gqlData: result.getReferralInfo)
            else {
                return .failure(.missingData)
            }

            return .success(referralInfo)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func getMyReferredUsers(after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let result = try await qlClient.fetch(query: GetMyReferredUsersQuery(offset: GraphQLNullable<Int>(integerLiteral: offset), limit: 20), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            let fetchedUsers = result.referralList.affectedRows.iInvited.compactMap { value in
                RowUser(gqlUser: value)
            }

            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func getMyUserInfo() async -> Result<OffensiveContentFilter, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetUserInfoQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard
                let filterValue = result.getUserInfo.affectedRows?.userPreferences?.contentFilteringSeverityLevel
            else {
                return .failure(.missingData)
            }

            switch filterValue {
                case .case(let filter):
                    return .success(OffensiveContentFilter.normalizedValue(from: filter))
                case .unknown(_):
                    return .failure(.missingData)
            }
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func fetchUser(with userId: String) async -> Result<User, APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let result = try await qlClient.fetch(query: GetProfileQuery(contentFilterBy: offensiveContentFilter.apiValue, userid: userId), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard
                let data = result.getProfile.affectedRows,
                let fetchedUser = User(gqlUser: data)
            else {
                return .failure(.missingData)
            }
            
            return .success(fetchedUser)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func fetchUserFollowers(for userID: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation = GetFollowersQuery(
                contentFilterBy: offensiveContentFilter.apiValue,
                userid: GraphQLNullable(stringLiteral: userID),
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )
            
            let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listFollowRelations.affectedRows?.followers else {
                return .failure(.missingData)
            }
            
            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }
            
            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func fetchUserFollowings(for userID: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation = GetFollowingsQuery(
                contentFilterBy: offensiveContentFilter.apiValue,
                userid: GraphQLNullable(stringLiteral: userID),
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )
            
            let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listFollowRelations.affectedRows?.following else {
                return .failure(.missingData)
            }
            
            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }
            
            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func fetchUserFriends(after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation = GetFriendsQuery(
                contentFilterBy: offensiveContentFilter.apiValue,
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )

            let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listFriends.affectedRows else {
                return .failure(.missingData)
            }

            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }

            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func fetchUsers(by query: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation = SearchUserQuery(
                contentFilterBy: offensiveContentFilter.apiValue,
                userid: nil,
                username: GraphQLNullable(stringLiteral: query.lowercased()),
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.searchUser.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }
            
            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func fetchDailyFreeLimits() async -> Result<DailyFreeQuota, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetDailyFreeQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let dataArray = result.getDailyFreeStatus.affectedRows else {
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
            return .failure(.unknownError(error: error))
        }
    }
    
    public func followUser(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: FollowUserMutation(userid: id))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func updateBio(new bio: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdateBioMutation(biography: bio))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func uploadProfileImage(new image: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdateAvatarMutation(img: image))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func updateUsername(username: String, currentPassword: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdateNameMutation(username: username, password: currentPassword))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func updatePassword(password: String, currentPassword: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdatePasswordMutation(password: password, expassword: currentPassword))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func updateEmail(email: String, currentPassword: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: UpdateMailMutation(email: email, password: currentPassword))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func toggleHideUserContent(with id: String) async -> Result<Bool, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: BlockUserMutation(userid: id))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            if result.getResponseCode == "11105" {

            }

            switch result.getResponseCode {
                case "11105":
                    return .success(true)
                case "11106":
                    return .success(false)
                default:
                    return .failure(.missingResponseCode)
            }
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func fetchUsersWithHiddenContent(after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let operation = GetBlockedUsersQuery(
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20
            )

            let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listBlockedUsers.affectedRows?.iBlocked else {
                return .failure(.missingData)
            }

            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }

            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func reportUser(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: ReportUserMutation(userid: id))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    //MARK: Posts
    public func fetchPostsByTitle(_ query: String, after offset: Int) async -> Result<[Post], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation = GetAllPostsQuery(
                filterBy: [.case(.image), .case(.text), .case(.video), .case(.audio)],
                contentFilterBy: offensiveContentFilter.apiValue,
                ignoreOption: .init(.no),
                sortBy: .some(.case(.newest)),
                title: GraphQLNullable(stringLiteral: query.lowercased()),
                tag: nil,
                from: nil,
                to: nil,
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20,
                commentOffset: nil,
                commentLimit: nil,
                postid: nil,
                userid: nil
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listPosts.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedPosts = data.compactMap { value in
                Post(gqlPost: value)
            }
            
            return .success(fetchedPosts)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func fetchPostsByTag(_ tag: String, after offset: Int) async -> Result<[Post], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation = GetAllPostsQuery(
                filterBy: [.case(.image), .case(.text), .case(.video), .case(.audio)],
                contentFilterBy: offensiveContentFilter.apiValue,
                ignoreOption: .init(.no),
                sortBy: .some(.case(.newest)),
                title: nil,
                tag: GraphQLNullable(stringLiteral: tag),
                from: nil,
                to: nil,
                offset: GraphQLNullable<Int>(integerLiteral: offset),
                limit: 20,
                commentOffset: nil,
                commentLimit: nil,
                postid: nil,
                userid: nil
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listPosts.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedPosts = data.compactMap { value in
                Post(gqlPost: value)
            }
            
            return .success(fetchedPosts)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func makePost(
        of type: ContentType,
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
                contentType: .case(type),
                title: title,
                media: GraphQLNullable<[String]>.some(content),
                mediadescription: GraphQLNullable(stringLiteral: contentDescitpion),
                tags: GraphQLNullable<[String]>.some(tags),
                cover: coverString
            )
            
            let result = try await qlClient.mutate(mutation: operation)
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func fetchPosts(
        with contentType: FeedContentType,
        sort byPopularity: FeedContentSortingByPopularity,
        showHiddenContent: Bool,
        filter byRelationship: FeedFilterByRelationship,
        in timeframe: FeedContentSortingByTime,
        after offset: Int,
        for userID: String?,
        amount: Int
    ) async -> Result<[Post], APIError> {
        let sortBy = byPopularity.apiValue

        var filterBy: [GraphQLEnum<PostFilterType>] = contentType.apiValue
        if let filterByAddition = byRelationship.apiValue {
            filterBy.append(filterByAddition)
        }

        let timeFrom = timeframe.apiValue.0
        let timeTo = timeframe.apiValue.1

        let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

        let operation = GetAllPostsQuery(
            filterBy: GraphQLNullable<[GraphQLEnum<PostFilterType>]>.some(filterBy),
            contentFilterBy: offensiveContentFilter.apiValue,
            ignoreOption: .init(showHiddenContent ? .no : .yes),
            sortBy: sortBy,
            title: nil,
            tag: nil,
            from: timeFrom != nil ? GraphQLNullable(stringLiteral: timeFrom!) : nil,
            to: timeTo != nil ? GraphQLNullable(stringLiteral: timeTo!) : nil,
            offset: GraphQLNullable<Int>(integerLiteral: offset),
            limit: GraphQLNullable<Int>(integerLiteral: amount),
            commentOffset: nil,
            commentLimit: nil,
            postid: nil,
            userid: userID == nil ? nil : GraphQLNullable(stringLiteral: userID!)
        )

        do {
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listPosts.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedPosts = data.compactMap { value in
                Post(gqlPost: value)
            }
            
            return .success(fetchedPosts)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func likePost(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.like)))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func dislikePost(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.dislike)))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func markPostViewed(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.view)))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func reportPost(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: PostActionMutation(postid: id, action: .case(.report)))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func getPostInteractions(with id: String, type: PostInteraction, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let result = try await qlClient.fetch(query: PostInteractionsQuery(getOnly: type.apiValue, postOrCommentId: id, offset: GraphQLNullable<Int>(integerLiteral: offset), limit: GraphQLNullable<Int>(integerLiteral: 20)), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.postInteractions?.affectedRows else {
                return .failure(.missingData)
            }

            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }

            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    //MARK: Comments
    public func fetchComments(for postID: String, after offset: Int) async -> Result<[Comment], APIError> {
        do {
            let offensiveContentFilter =  UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "offensiveContentFilter").flatMap(OffensiveContentFilter.init(rawValue:)) ?? .blocked

            let operation =  GetPostCommentsQuery(
                contentFilterBy: offensiveContentFilter.apiValue,
                postid: postID,
                commentLimit: GraphQLNullable<Int>(integerLiteral: 20),
                commentOffset: GraphQLNullable<Int>(integerLiteral: offset)
            )
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.listPosts.affectedRows?.first?.comments else {
                return .failure(.missingData)
            }
            
            let fetchedComments = data.compactMap { value in
                Comment(gqlComment: value)
            }
            
            return .success(fetchedComments)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func sendComment(for postID: String, with content: String) async -> Result<Comment, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: CreateCommentMutation(postid: postID, parentid: nil, content: content))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.createComment.affectedRows?.first,
                  case let .some(commentData) = data,
                  let comment = Comment(gqlComment: commentData)
            else {
                return .failure(.missingData)
            }
            
            return .success(comment)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    public func likeComment(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: LikeCommentMutation(commentid: id))
            
            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func reportComment(with id: String) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: ReportCommentMutation(commentid: id))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func getCommentInteractions(with id: String, after offset: Int) async -> Result<[RowUser], APIError> {
        do {
            let result = try await qlClient.fetch(query: PostInteractionsQuery(getOnly: .case(.commentlike), postOrCommentId: id, offset: GraphQLNullable<Int>(integerLiteral: offset), limit: GraphQLNullable<Int>(integerLiteral: 20)), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.postInteractions?.affectedRows else {
                return .failure(.missingData)
            }

            let fetchedUsers = data.compactMap { value in
                RowUser(gqlUser: value)
            }

            return .success(fetchedUsers)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    //MARK: Tags
    public func fetchTags(with query: String) async -> Result<[String], APIError> {
        do {
            let operation = SearchTagsQuery(tagName: query, offset: 0, limit: 20)
            let result = try await qlClient.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard let data = result.searchTags.affectedRows else {
                return .failure(.missingData)
            }
            
            let fetchedTags = data
                .compactMap{ $0 }
                .map{ $0.name }
            
            return .success(fetchedTags)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
    
    //MARK: Wallet
    public func fetchLiquidityState() async -> Result<Double, APIError> {
        do {
            let result = try await qlClient.fetch(query: GetLiquidityQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            guard
                let data = result.balance.currentliquidity,
                let amount = Double(data)
            else {
                return .failure(.missingData)
            }

            return .success(amount)
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

    public func transferTokens(to id: String, amount: Int) async -> Result<Void, APIError> {
        do {
            let result = try await qlClient.mutate(mutation: TransferTokensMutation(recipient: id, numberoftokens: amount))

            guard result.isResponseCodeSuccess else {
                if let errorCode = result.getResponseCode {
                    return .failure(.serverError(code: errorCode))
                } else {
                    return .failure(.missingResponseCode)
                }
            }

            return .success(())
        } catch {
            return .failure(.unknownError(error: error))
        }
    }
}
