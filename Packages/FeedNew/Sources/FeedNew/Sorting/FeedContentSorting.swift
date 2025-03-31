//
//  FeedContentSorting.swift
//  FeedNew
//
//  Created by Artem Vasin on 17.03.25.
//

import SwiftUI
import GQLOperationsUser

public enum FeedContentSortingByTime: String, CaseIterable {
    case allTime = "All Time"
    case today = "Today"
    case week = "This Week"
    case month = "This Month"

    public var apiValue: (String?, String?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let calendar = Calendar.current
        let today = Foundation.Date()

        switch self {
            case .allTime:
                return (nil, nil)

            case .today: // return today's day and next day
                let nextDay = calendar.date(byAdding: .day, value: 1, to: today)!
                let todayString = formatter.string(from: today)
                let nextDayString = formatter.string(from: nextDay)
                return (todayString, nextDayString)

            case .week:
                let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)!
                let nextDay = calendar.date(byAdding: .day, value: 1, to: today)!
                let nextDayString = formatter.string(from: nextDay)
                let sevenDaysAgoString = formatter.string(from: sevenDaysAgo)
                return (sevenDaysAgoString, nextDayString)

            case .month:
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
                let nextDay = calendar.date(byAdding: .day, value: 1, to: today)!
                let nextDayString = formatter.string(from: nextDay)
                let thirtyDaysAgoString = formatter.string(from: thirtyDaysAgo)
                return (thirtyDaysAgoString, nextDayString)
        }
    }
}

public enum FeedContentSortingByPopularity: String, CaseIterable {
    case newest = "Newest"
    case trending = "Trending"
    case mostLiked = "Most Liked"
    case mostDisliked = "Most Disliked"
    case mostViewed = "Most Viewed"
    case mostCommented = "Most Commented"

    public var apiValue: GraphQLNullable<GraphQLEnum<SortType>> {
        switch self {
            case .newest: return .some(.case(.newest))
            case .trending: return .some(.case(.trending))
            case .mostLiked: return .some(.case(.likes))
            case .mostDisliked : return .some(.case(.dislikes))
            case .mostViewed: return .some(.case(.views))
            case .mostCommented: return .some(.case(.comments))
        }
    }
}

public enum FeedFilterByRelationship: String, CaseIterable {
    case all = "All"
    case myFollowers = "Followers"
    case whoIAmFollowing = "Following"

    public var apiValue: GraphQLEnum<FilterType>? {
        switch self {
            case .all: return nil
            case .myFollowers: return .case(.followed)
            case .whoIAmFollowing: return .case(.follower)
        }
    }
}

@MainActor
public final class FeedContentSortingAndFiltering: ObservableObject {
    class Storage {
        @AppStorage("feed_sort_time") var sortByTime: FeedContentSortingByTime = .allTime
        @AppStorage("feed_sort_popularity") var sortByPopularity: FeedContentSortingByPopularity = .newest
        @AppStorage("feed_filter_relationship") var filterByRelationship: FeedFilterByRelationship = .all
    }

    public static let shared = FeedContentSortingAndFiltering()

    private let storage = Storage()

    @Published public var sortByTime: FeedContentSortingByTime {
        didSet {
            storage.sortByTime = sortByTime
        }
    }
    @Published public var sortByPopularity: FeedContentSortingByPopularity {
        didSet {
            storage.sortByPopularity = sortByPopularity
        }
    }
    @Published public var filterByRelationship: FeedFilterByRelationship {
        didSet {
            storage.filterByRelationship = filterByRelationship
        }
    }

    private init() {
        sortByTime = storage.sortByTime
        sortByPopularity = storage.sortByPopularity
        filterByRelationship = storage.filterByRelationship
    }
}
