//
//  SingleAdStats.swift
//  Models
//
//  Created by Artem Vasin on 04.11.25.
//

import GQLOperationsUser

public struct SingleAdStats: Identifiable, Hashable {
    public let id: String
    public let adType: AdType
    public let creationDate: String
    public let startDate: String
    public let endDate: String
    public let tokenCost: Double
    public let gemsEarned: Double
    public let amountLikes: Int
    public let amountDislikes: Int
    public let amountViews: Int
    public let amountComments: Int
    public let amountReports: Int
    public let post: Post

    public init?(gqlAd: GetAdsHistoryListQuery.Data.AdvertisementHistory.AffectedRows.Advertisement?) {
        guard let gqlAd else { return nil }

        guard
            let post = Post(gqlPost: gqlAd.post)
        else {
            return nil
        }

        self.id = gqlAd.id
        self.adType = .pinned
        self.creationDate = gqlAd.createdAt
        self.startDate = gqlAd.timeframeStart
        self.endDate = gqlAd.timeframeEnd
        self.tokenCost = gqlAd.totalTokenCost
        self.gemsEarned = gqlAd.gemsEarned
        self.amountLikes = gqlAd.amountLikes
        self.amountDislikes = gqlAd.amountDislikes
        self.amountViews = gqlAd.amountViews
        self.amountComments = gqlAd.amountComments
        self.amountReports = gqlAd.amountReports
        self.post = post
    }
}
