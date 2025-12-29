//
//  RowUser.swift
//  Models
//
//  Created by Артем Васин on 31.12.24.
//

import Foundation
import GQLOperationsUser

public struct RowUser: Identifiable, Hashable {
    public let id: String
    public let username: String
    public let slug: Int
    public let image: String
    public let isFollowed: Bool
    public let isFollowing: Bool

    public let hasActiveReports: Bool
    public let isHiddenForUsers: Bool
    public let visibilityStatus: ContentVisibilityStatus

    public var imageURL: URL? {
        guard image != "" else { return nil }
        return URL(string: "\(Constants.mediaURL)\(image)")
    }
    
    public init(
        id: String,
        username: String,
        slug: Int,
        image: String,
        isFollowed: Bool,
        isFollowing: Bool,
        hasActiveReports: Bool = false,
        isHiddenForUsers: Bool = false,
        visibilityStatus: ContentVisibilityStatus = .normal
    ) {
        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = hasActiveReports
        self.isHiddenForUsers = isHiddenForUsers
        self.visibilityStatus = visibilityStatus
    }

    public init?(gqlUser: GetFollowersQuery.Data.ListFollowRelations.AffectedRows.Follower) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetFollowingsQuery.Data.ListFollowRelations.AffectedRows.Following) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetFriendsQuery.Data.ListFriends.AffectedRow?) {
        guard
            let gqlUser,
            let id = gqlUser.userid,
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = true
        self.isFollowing = true
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: SearchUserQuery.Data.SearchUser.AffectedRow?) {
        guard
            let gqlUser,
            let id = gqlUser.id,
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = false
        self.isFollowing = false
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetMyInviterQuery.Data.ReferralList.AffectedRows.InvitedBy) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetMyReferredUsersQuery.Data.ReferralList.AffectedRows.IInvited) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetBlockedUsersQuery.Data.ListBlockedUsers.AffectedRows.IBlocked) {
        guard
            let id = gqlUser.userid,
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = false
        self.isFollowing = false
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: PostInteractionsQuery.Data.PostInteractions.AffectedRow) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetListOfAdsQuery.Data.ListAdvertisementPosts.AffectedRow.Advertisement.User) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetAdsHistoryListQuery.Data.AdvertisementHistory.AffectedRows.Advertisement.User) {
        guard
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing
        else {
            return nil
        }

        self.id = gqlUser.id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.hasActiveReports = gqlUser.hasActiveReports
        self.isHiddenForUsers = gqlUser.isHiddenForUsers
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus.value)
    }

    public init?(gqlUser: GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Recipient) {
        guard
            let id = gqlUser.userid,
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = false
        self.isFollowing = false
    }

    public init?(gqlUser: GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Sender) {
        guard
            let id = gqlUser.userid,
            let username = gqlUser.username,
            let slug = gqlUser.slug,
            let image = gqlUser.img
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = false
        self.isFollowing = false
    }
}

extension RowUser {
    public static func placeholders(count: Int = 10) -> [RowUser] {
        return (0..<count).map { _ in
            RowUser(
                id: UUID().uuidString,
                username: "Username Username",
                slug: 23910,
                image: "",
                isFollowed: false,
                isFollowing: false
            )
        }
    }
}
