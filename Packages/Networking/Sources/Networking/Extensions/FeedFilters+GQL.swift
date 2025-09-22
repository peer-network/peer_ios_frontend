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
            case .image:
                [.case(.image)]
            case .imageAndVideo:
                [.case(.image), .case(.video)]
            case .all:
                [.case(.audio), .case(.video), .case(.image), .case(.text)]
        }
    }
}

extension FeedFilterByRelationship {
    var apiValue: GraphQLEnum<PostFilterType>? {
        switch self {
            case .all: return nil
            case .myFollowers: return .case(.follower)
            case .whoIAmFollowing: return .case(.followed)
        }
    }
}

extension FeedContentSortingByPopularity {
    var apiValue: GraphQLNullable<GraphQLEnum<PostSortType>> {
        switch self {
            case .forYou: return .some(.case(.forMe))
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

extension OffensiveContentFilter {
    public var apiValue: GraphQLNullable<GraphQLEnum<ContentFilterType>> {
        switch self {
            case .allowed:
                return .some(.case(.mygrandmahates))
            case .blocked:
                return .some(.case(.mygrandmalikes))
        }
    }

    public static func normalizedValue(from apiValue: ContentFilterType) -> OffensiveContentFilter {
        switch apiValue {
            case .mygrandmahates:
                return .allowed
            case .mygrandmalikes:
                return .blocked
        }
    }
}

extension PostInteraction {
    public var apiValue: GraphQLEnum<GetOnly> {
        switch self {
            case .likes: return .case(.like)
            case .dislikes: return .case(.dislike)
            case .views: return .case(.view)
        }
    }
}

extension Onboarding {
    public var apiValue: GraphQLEnum<OnboardingType> {
        switch self {
            case .intro:
                return .case(.introonboarding)
        }
    }

    public static func normalizedValue(from apiValue: [GraphQLEnum<OnboardingType>]) -> [Onboarding] {
        let onboardings = apiValue.compactMap { apiOnboarding in
            switch apiOnboarding {
                case .case(let apiOnboarding):
                    switch apiOnboarding {
                        case .introonboarding:
                            return Onboarding.intro
                    }
                case .unknown(_):
                    return nil
            }
        }
        return onboardings
    }
}
