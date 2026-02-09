//
//  DailyFreeQuotaDTO.swift
//  Networking
//
//  Created by Artem Vasin on 09.02.26.
//

public struct DailyFreeQuotaDTO {
    public let likes: Int
    public let posts: Int
    public let comments: Int

    public init(likes: Int, posts: Int, comments: Int) {
        self.likes = likes
        self.posts = posts
        self.comments = comments
    }
}
