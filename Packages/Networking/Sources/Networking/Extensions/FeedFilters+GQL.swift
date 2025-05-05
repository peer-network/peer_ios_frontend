//
//  FeedFilters+GQL.swift
//  Networking
//
//  Created by Alexander Savchenko on 03.04.25.
//

import Models
import GQLOperationsUser
import Foundation

extension FeedContentType {
    var apiValue: [GraphQLEnum<PostFilterType>] {
        switch self {
        case .regular:
            [.case(.text), .case(.image)]
        case .audio:
            [.case(.audio)]
        case .video:
            [.case(.video)]
        }
    }
}

extension FeedFilterByRelationship {
    var apiValue: GraphQLEnum<PostFilterType>? {
        switch self {
            case .all: return nil
            case .myFollowers: return .case(.followed)
            case .whoIAmFollowing: return .case(.follower)
        }
    }
}

extension FeedContentSortingByPopularity {
    var apiValue: GraphQLNullable<GraphQLEnum<PostSortType>> {
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

extension FeedContentSortingByTime {
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
