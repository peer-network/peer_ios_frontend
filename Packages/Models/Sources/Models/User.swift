//
//  User.swift
//  Models
//
//  Created by Артем Васин on 23.12.24.
//

import GQLOperationsUser
import Foundation

public struct User: Identifiable, Hashable {
    public let id: String
    public let username: String
    public let status: Int
    public let slug: Int
    public let image: String
    public let biography: String
    public let postsAmount: Int
    public let isFollowed: Bool
    public let isFollowing: Bool
    public let amountFollowers: Int
    public let amountFollowing: Int
    public let amountFriends: Int

    public let hasActiveReports: Bool = true
    public let visibilityStatus: ContentVisibilityStatus = .hidden

    public var imageURL: URL? {
        guard image != "" else { return nil }
        return URL(string: "\(Constants.mediaURL)\(image)")
    }

    public var bioURL: URL? {
        URL(string: "\(Constants.mediaURL)\(biography)")
    }

    public init(
        id: String,
        username: String,
        status: Int,
        slug: Int,
        image: String,
        biography: String,
        postsAmount: Int,
        isFollowed: Bool,
        isFollowing: Bool,
        amountFollowers: Int,
        amountFollowing: Int,
        amountFriends: Int
    ) {
        self.id = id
        self.username = username
        self.status = status
        self.slug = slug
        self.image = image
        self.biography = biography
        self.postsAmount = postsAmount
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.amountFollowers = amountFollowers
        self.amountFollowing = amountFollowing
        self.amountFriends = amountFriends
    }

    //TODO: Replace Apollo struct with raw params
    public init?(gqlUser: GetProfileQuery.Data.GetProfile.AffectedRows) {
        guard
            //TODO: exclude checks for parameters that could be considered as optionals
            let id = gqlUser.id,
            let username = gqlUser.username,
            let status = gqlUser.status,
            let slug = gqlUser.slug,
            let image = gqlUser.img,
            let biography = gqlUser.biography,
            let postsAmount = gqlUser.amountposts,
            let isFollowed = gqlUser.isfollowed,
            let isFollowing = gqlUser.isfollowing,
            let amountFollowers = gqlUser.amountfollowed,
            let amountFollowing = gqlUser.amountfollower,
            let amountFriends = gqlUser.amountfriends
        else {
            return nil
        }

        self.id = id
        self.username = username
        self.status = status
        self.slug = slug
        self.image = image
        self.biography = biography
        self.postsAmount = postsAmount
        self.isFollowed = isFollowed
        self.isFollowing = isFollowing
        self.amountFollowers = amountFollowers
        self.amountFollowing = amountFollowing
        self.amountFriends = amountFriends
    }
}

extension User {
    public static func placeholder() -> User {
        return User(
            id: UUID().uuidString,
            username: "Username Username",
            status: 1,
            slug: 23910,
            image: "https://dummyimage.com/200x200/000/fff",
            biography: "This is a placeholder biography.",
            postsAmount: 30,
            isFollowed: false,
            isFollowing: false,
            amountFollowers: 30,
            amountFollowing: 30,
            amountFriends: 30
        )
    }

    public static func placeholders() -> [User] {
        return Array(repeating: .placeholder(), count: 10)
    }
}
