//
//  ObjectOwner.swift
//  Models
//
//  Created by Артем Васин on 19.12.24.
//

import GQLOperationsUser
import Foundation

public struct ObjectOwner: Identifiable, Hashable {
    public let id: String
    public let username: String
    public let slug: Int
    public let image: String
    public var isFollowing: Bool
    public var isFollowed: Bool

    public let hasActiveReports: Bool
    public let visibilityStatus: ContentVisibilityStatus

    public var imageURL: URL? {
        URL(string: "\(Constants.mediaURL)\(image)")
    }

    public init(
        id: String,
        username: String,
        slug: Int,
        image: String,
        isFollowing: Bool,
        isFollowed: Bool,
        hasActiveReports: Bool = false,
        visibilityStatus: ContentVisibilityStatus = .normal
    ) {
        self.id = id
        self.username = username
        self.slug = slug
        self.image = image
        self.isFollowing = isFollowing
        self.isFollowed = isFollowed
        self.hasActiveReports = hasActiveReports
        self.visibilityStatus = visibilityStatus
    }

    public init?(gqlUser: GetPostCommentsQuery.Data.ListPosts.AffectedRow.Comment.User) {
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
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus!.value)
    }

    public init?(gqlUser: GetAllPostsQuery.Data.ListPosts.AffectedRow.User) {
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
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus!.value)
    }

    public init?(gqlUser: GetPostByIdQuery.Data.ListPosts.AffectedRow.User) {
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
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus!.value)
    }

    public init?(gqlUser: CreateCommentMutation.Data.CreateComment.AffectedRow.User) {
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
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus!.value)
    }

    public init?(gqlUser: GetListOfAdsQuery.Data.ListAdvertisementPosts.AffectedRow.Post.User) {
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
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus!.value)
    }

    public init?(gqlUser: GetAdsHistoryListQuery.Data.AdvertisementHistory.AffectedRows.Advertisement.Post.User) {
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
        self.visibilityStatus = .normalizedValue(gqlUser.visibilityStatus!.value)
    }
}

extension ObjectOwner {
    public static func placeholder() -> ObjectOwner {
        return ObjectOwner(
            id: UUID().uuidString,
            username: "Ender Peer",
            slug: 23910,
            image: "",
            isFollowing: false,
            isFollowed: false
        )
    }
    
    public static func placeholders(count: Int = 10) -> [ObjectOwner] {
        return (0..<count).map { _ in
            ObjectOwner(
                id: UUID().uuidString,
                username: "Ender Peer",
                slug: 23910,
                image: "",
                isFollowing: false,
                isFollowed: false
            )
        }
    }
}
