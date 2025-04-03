//
//  DailyFreeQuota.swift
//  Models
//
//  Created by Alexander Savchenko on 02.04.25.
//

public struct DailyFreeQuota {
    private(set) var likes: Int
    private(set) var posts: Int
    private(set) var comments: Int
    
    public init(likes: Int, posts: Int, comments: Int) {
        self.likes = likes
        self.posts = posts
        self.comments = comments
    }
    
    //TODO: Add mutating funcs to control state of variables
}
