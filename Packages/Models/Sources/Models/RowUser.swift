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
        isFollowing: Bool
    ) {
        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
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
    }

    public init?(gqlUser: GetFriendsQuery.Data.ListFriends.AffectedRow?) {
        guard
            let id = gqlUser?.userid,
            let username = gqlUser?.username,
            let slug = gqlUser?.slug,
            let image = gqlUser?.img
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowed = true
        self.isFollowing = true
    }

    public init?(gqlUser: SearchUserQuery.Data.SearchUser.AffectedRow?) {
        guard
            let id = gqlUser?.id,
            let username = gqlUser?.username,
            let image = gqlUser?.img,
            let slug = gqlUser?.slug
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
