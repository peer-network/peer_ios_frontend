//
//  Post.swift
//  Models
//
//  Created by Артем Васин on 19.12.24.
//

import Foundation
import GQLOperationsUser

public struct Post: Identifiable, Hashable {
    public enum ContentType: String, Codable {
        case text
        case image
        case video
        case audio
    }
    
    public let id: String
    public var contentType: ContentType
    public var title: String
    public var media: [MediaItem]
    public var cover: [MediaItem]
    public var mediaDescription: String
    public var createdAt: String
    public var amountLikes: Int
    public var amountViews: Int
    public var amountComments: Int
    public var amountDislikes: Int
    public var isLiked: Bool
    public var isViewed: Bool
    public var isReported: Bool
    public var isDisliked: Bool
    public var isSaved: Bool
    public var tags: [String]
    public let url: String
    public var owner: ObjectOwner

    public let advertisement: Advertisement?

    public let hasActiveReports: Bool = false
    public let visibilityStatus: ContentVisibilityStatus = .hidden

    public var mediaURLs: [URL] {
        media.compactMap {
            URL(string: "\(Constants.mediaURL)\($0.path)")
        }
    }

    public var coverURL: URL? {
        guard let coverPath = cover.first?.path else { return nil }
        return URL(string: "\(Constants.mediaURL)\(coverPath)")
    }

    public var shareURL: URL? {
        URL(string: url)
    }

    public var formattedCreatedAtShort: String {
        return createdAt.timeAgo(isShort: true)
    }

    public var formattedCreatedAtLong: String {
        return createdAt.timeAgo(isShort: false)
    }

    public init?(gqlPost: GetAllPostsQuery.Data.ListPosts.AffectedRow) {
        guard
            let contentType = ContentType(rawValue: gqlPost.contenttype),
            let postOwner = ObjectOwner(gqlUser: gqlPost.user),
            let mediaData = gqlPost.media.data(using: .utf8),
            let parsedMedia = try? JSONDecoder().decode([MediaItem].self, from: mediaData)
        else {
            return nil
        }

        self.id = gqlPost.id
        self.contentType = contentType
        self.title = gqlPost.title
        self.media = parsedMedia
        if !gqlPost.cover.isEmpty,
           let coverData = gqlPost.cover.data(using: .utf8),
           let parsedCover = try? JSONDecoder().decode([MediaItem].self, from: coverData)
        {
            self.cover = parsedCover
        } else {
            self.cover = []
        }
        self.mediaDescription = gqlPost.mediadescription
        self.createdAt = gqlPost.createdat
        self.amountLikes = gqlPost.amountlikes
        self.amountViews = gqlPost.amountviews
        self.amountComments = gqlPost.amountcomments
        self.amountDislikes = gqlPost.amountdislikes
        self.isLiked = gqlPost.isliked
        self.isViewed = gqlPost.isviewed
        self.isReported = gqlPost.isreported
        self.isDisliked = gqlPost.isdisliked
        self.isSaved = gqlPost.issaved
        self.tags = gqlPost.tags as? [String] ?? []
        self.url = gqlPost.url
        self.owner = postOwner
        advertisement = nil
    }

    public init?(gqlPost: GetPostByIdQuery.Data.ListPosts.AffectedRow) {
        guard
            let contentType = ContentType(rawValue: gqlPost.contenttype),
            let postOwner = ObjectOwner(gqlUser: gqlPost.user),
            let mediaData = gqlPost.media.data(using: .utf8),
            let parsedMedia = try? JSONDecoder().decode([MediaItem].self, from: mediaData)
        else {
            return nil
        }

        self.id = gqlPost.id
        self.contentType = contentType
        self.title = gqlPost.title
        self.media = parsedMedia
        if !gqlPost.cover.isEmpty,
           let coverData = gqlPost.cover.data(using: .utf8),
           let parsedCover = try? JSONDecoder().decode([MediaItem].self, from: coverData)
        {
            self.cover = parsedCover
        } else {
            self.cover = []
        }
        self.mediaDescription = gqlPost.mediadescription
        self.createdAt = gqlPost.createdat
        self.amountLikes = gqlPost.amountlikes
        self.amountViews = gqlPost.amountviews
        self.amountComments = gqlPost.amountcomments
        self.amountDislikes = gqlPost.amountdislikes
        self.isLiked = gqlPost.isliked
        self.isViewed = gqlPost.isviewed
        self.isReported = gqlPost.isreported
        self.isDisliked = gqlPost.isdisliked
        self.isSaved = gqlPost.issaved
        self.tags = gqlPost.tags as? [String] ?? []
        self.url = gqlPost.url
        self.owner = postOwner
        advertisement = nil
    }

    public init?(gqlAdvertisement: GetListOfAdsQuery.Data.ListAdvertisementPosts.AffectedRow) {
        let gqlPost = gqlAdvertisement.post

        guard
            let contentType = ContentType(rawValue: gqlPost.contenttype),
            let postOwner = ObjectOwner(gqlUser: gqlPost.user),
            let mediaData = gqlPost.media.data(using: .utf8),
            let parsedMedia = try? JSONDecoder().decode([MediaItem].self, from: mediaData)
        else {
            return nil
        }

        self.id = gqlPost.id
        self.contentType = contentType
        self.title = gqlPost.title
        self.media = parsedMedia
        if !gqlPost.cover.isEmpty,
           let coverData = gqlPost.cover.data(using: .utf8),
           let parsedCover = try? JSONDecoder().decode([MediaItem].self, from: coverData)
        {
            self.cover = parsedCover
        } else {
            self.cover = []
        }
        self.mediaDescription = gqlPost.mediadescription
        self.createdAt = gqlPost.createdat
        self.amountLikes = gqlPost.amountlikes
        self.amountViews = gqlPost.amountviews
        self.amountComments = gqlPost.amountcomments
        self.amountDislikes = gqlPost.amountdislikes
        self.isLiked = gqlPost.isliked
        self.isViewed = gqlPost.isviewed
        self.isReported = gqlPost.isreported
        self.isDisliked = gqlPost.isdisliked
        self.isSaved = gqlPost.issaved
        self.tags = gqlPost.tags as? [String] ?? []
        self.url = gqlPost.url
        self.owner = postOwner
        advertisement = Advertisement(gqlAdvertisement: gqlAdvertisement)
    }

    public init?(gqlPost: GetAdsHistoryListQuery.Data.AdvertisementHistory.AffectedRows.Advertisement.Post) {
        guard
            let contentType = ContentType(rawValue: gqlPost.contenttype),
            let postOwner = ObjectOwner(gqlUser: gqlPost.user),
            let mediaData = gqlPost.media.data(using: .utf8),
            let parsedMedia = try? JSONDecoder().decode([MediaItem].self, from: mediaData)
        else {
            return nil
        }

        self.id = gqlPost.id
        self.contentType = contentType
        self.title = gqlPost.title
        self.media = parsedMedia
        if !gqlPost.cover.isEmpty,
           let coverData = gqlPost.cover.data(using: .utf8),
           let parsedCover = try? JSONDecoder().decode([MediaItem].self, from: coverData)
        {
            self.cover = parsedCover
        } else {
            self.cover = []
        }
        self.mediaDescription = gqlPost.mediadescription
        self.createdAt = gqlPost.createdat
        self.amountLikes = gqlPost.amountlikes
        self.amountViews = gqlPost.amountviews
        self.amountComments = gqlPost.amountcomments
        self.amountDislikes = gqlPost.amountdislikes
        self.isLiked = gqlPost.isliked
        self.isViewed = gqlPost.isviewed
        self.isReported = gqlPost.isreported
        self.isDisliked = gqlPost.isdisliked
        self.isSaved = gqlPost.issaved
        self.tags = gqlPost.tags as? [String] ?? []
        self.url = gqlPost.url
        self.owner = postOwner
        advertisement = nil
    }

    public init(
        id: String,
        contentType: ContentType,
        title: String,
        media: [MediaItem],
        cover: [MediaItem],
        mediaDescription: String,
        createdAt: String,
        amountLikes: Int,
        amountViews: Int,
        amountComments: Int,
        amountDislikes: Int,
        isLiked: Bool,
        isViewed: Bool,
        isReported: Bool,
        isDisliked: Bool,
        isSaved: Bool,
        tags: [String],
        url: String,
        owner: ObjectOwner
    ) {
        self.id = id
        self.contentType = contentType
        self.title = title
        self.media = media
        self.cover = cover
        self.mediaDescription = mediaDescription
        self.createdAt = createdAt
        self.amountLikes = amountLikes
        self.amountViews = amountViews
        self.amountComments = amountComments
        self.amountDislikes = amountDislikes
        self.isLiked = isLiked
        self.isViewed = isViewed
        self.isReported = isReported
        self.isDisliked = isDisliked
        self.isSaved = isSaved
        self.tags = tags
        self.url = url
        self.owner = owner
        advertisement = nil
    }
}

extension Post {
    /// ID which is used for UI to identify if a view related to this post should be redrawn
    public var refreshID: String {
        "\(id)-\(amountLikes)-\(amountDislikes)-\(amountViews)-\(amountComments)-\(isLiked)-\(isDisliked)-\(isViewed)-\(owner.isFollowing)-\(owner.isFollowed)"
    }
}

extension Post {
    public static func placeholderText() -> Post {
        return Post(
            id: UUID().uuidString,
            contentType: .text,
            title: "Placeholder Title",
            media: [],
            cover: [],
            mediaDescription: "Lorem ipsum dolor sit amet sed lorem dolore takimata et elitr vel nulla est sanctus lorem. Dolor in elit magna enim tempor aliquam dolore et ea voluptua dolor ut dolor sit ipsum eros accusam.",
            createdAt: Date.now.description,
            amountLikes: 10,
            amountViews: 20,
            amountComments: 10,
            amountDislikes: 1,
            isLiked: false,
            isViewed: false,
            isReported: false,
            isDisliked: false,
            isSaved: false,
            tags: ["placeholder", "example", "text"],
            url: "",
            owner: ObjectOwner.placeholder()
        )
    }

    public static func placeholders(count: Int = 10) -> [Post] {
        return Array(repeating: .placeholderText(), count: count)
    }

    public static func placeholdersImage(count: Int = 10) -> [Post] {
        return (0..<count).map { _ in
            Post(
                id: UUID().uuidString,
                contentType: .image,
                title: "Placeholder Title",
                media: [MediaItem(path: "/image/5edde530-f3e6-4862-a5a8-1ab24bf457a8.jpeg", options: nil)],
                cover: [],
                mediaDescription: "Lorem ipsum dolor sit amet sed lorem dolore takimata et elitr vel nulla.",
                createdAt: Date.now.description,
                amountLikes: 10,
                amountViews: 20,
                amountComments: 10,
                amountDislikes: 1,
                isLiked: false,
                isViewed: false,
                isReported: false,
                isDisliked: false,
                isSaved: false,
                tags: ["placeholder", "example", "text"],
                url: "",
                owner: ObjectOwner.placeholder()
            )
        }
    }
}
