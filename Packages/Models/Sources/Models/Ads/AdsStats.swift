//
//  AdsStats.swift
//  Models
//
//  Created by Artem Vasin on 03.11.25.
//

import GQLOperationsUser

public struct AdsStats {
    public let amountAds: Int
    public let tokenSpent: Double
    public let gemsEarned: Double
    public let amountLikes: Int
    public let amountDislikes: Int
    public let amountViews: Int
    public let amountComments: Int
    public let amountReports: Int

    public init?(gqlAdsStats: GetAdsHistoryStatsQuery.Data.AdvertisementHistory.AffectedRows.Stats) {
        self.amountAds = gqlAdsStats.amountAds
        self.tokenSpent = gqlAdsStats.tokenSpent
        self.gemsEarned = gqlAdsStats.gemsEarned
        self.amountLikes = gqlAdsStats.amountLikes
        self.amountDislikes = gqlAdsStats.amountDislikes
        self.amountViews = gqlAdsStats.amountViews
        self.amountComments = gqlAdsStats.amountComments
        self.amountReports = gqlAdsStats.amountReports
    }
}
