//
//  Comment.swift
//  Models
//
//  Created by Артем Васин on 19.12.24.
//

import Foundation
import GQLOperationsUser

public struct Comment: Identifiable, Hashable {
    public let id: String
    public let userId: String
    public let postId: String
    public let parentId: String
    public let content: String
    public var amountLikes: Int
    public var isLiked: Bool
    public let createdAt: String
    public let user: ObjectOwner

    public let hasActiveReports: Bool = false
    public let visibilityStatus: ContentVisibilityStatus = .illegal

    public var formattedCreatedAt: String {
        return createdAt.timeAgo(isShort: true)
    }

    public init(
        id: String,
        userId: String,
        postId: String,
        parentId: String,
        content: String,
        amountLikes: Int,
        isLiked: Bool,
        createdAt: String,
        user: ObjectOwner
    ) {
        self.id = id
        self.userId = userId
        self.postId = postId
        self.parentId = parentId
        self.content = content
        self.amountLikes = amountLikes
        self.isLiked = isLiked
        self.createdAt = createdAt
        self.user = user
    }

    public init?(gqlComment: GetPostCommentsQuery.Data.ListPosts.AffectedRow.Comment) {
        guard
            let parentId = gqlComment.parentid,
            let user = ObjectOwner(gqlUser: gqlComment.user)
        else {
            return nil
        }

        self.id = gqlComment.commentid
        self.userId = gqlComment.userid
        self.postId = gqlComment.postid
        self.parentId = parentId
        self.content = gqlComment.content
        self.amountLikes = gqlComment.amountlikes
        self.isLiked = gqlComment.isliked
        self.createdAt = gqlComment.createdat
        self.user = user
    }

    public init?(gqlComment: CreateCommentMutation.Data.CreateComment.AffectedRow) {
        guard
            let parentId = gqlComment.parentid,
            let user = ObjectOwner(gqlUser: gqlComment.user)
        else {
            return nil
        }

        self.id = gqlComment.commentid
        self.userId = gqlComment.userid
        self.postId = gqlComment.postid
        self.parentId = parentId
        self.content = gqlComment.content
        self.amountLikes = gqlComment.amountlikes
        self.isLiked = gqlComment.isliked
        self.createdAt = gqlComment.createdat
        self.user = user
    }
}

extension Comment {
    public static func placeholder() -> Comment {
        return Comment(
            id: UUID().uuidString,
            userId: UUID().uuidString,
            postId: UUID().uuidString,
            parentId: "",
            content: "This is a placeholder comment.",
            amountLikes: 10,
            isLiked: false,
            createdAt: "2025-04-28 08:14:22.782181",
            user: ObjectOwner.placeholder()
        )
    }
    
    public static func placeholders(count: Int = 10) -> [Comment] {
        return (0..<count).map { _ in
            Comment(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                postId: UUID().uuidString,
                parentId: "",
                content: "This is a placeholder comment.",
                amountLikes: 10,
                isLiked: false,
                createdAt: "2025-04-28 08:14:22.782181",
                user: ObjectOwner.placeholder()
            )
        }
    }
}
