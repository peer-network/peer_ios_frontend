//
//  ContentFilterTypes.swift
//  Models
//
//  Created by Alexander Savchenko on 03.04.25.
//

public enum FeedContentType: String, CaseIterable {
    case regular
    case audio
    case video
    case image
}

public enum FeedContentSortingByTime: String, CaseIterable {
    case allTime = "All Time"
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
}

public enum FeedContentSortingByPopularity: String, CaseIterable {
    case newest = "Newest"
    case trending = "Trending"
    case mostLiked = "Most Liked"
    case mostDisliked = "Most Disliked"
    case mostViewed = "Most Viewed"
    case mostCommented = "Most Commented"
}

public enum FeedFilterByRelationship: String, CaseIterable {
    case all = "All"
    case myFollowers = "Followers"
    case whoIAmFollowing = "Following"
}
