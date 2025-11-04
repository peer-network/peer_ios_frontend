//
//  Advertisement.swift
//  Models
//
//  Created by Artem Vasin on 14.10.25.
//

import Foundation
import GQLOperationsUser

public struct Advertisement: Identifiable, Hashable {
    public let id: String
    public let adType: AdType
    public let creationDate: String
    public let startDate: String
    public let endDate: String
    public let adOwner: RowUser

    public init?(gqlAdvertisement: GetListOfAdsQuery.Data.ListAdvertisementPosts.AffectedRow) {
        guard
            let adOwner = RowUser(gqlUser: gqlAdvertisement.advertisement.user)
        else {
            return nil
        }

        self.id = gqlAdvertisement.advertisement.advertisementid
        self.adType = .pinned
        self.creationDate = gqlAdvertisement.advertisement.createdat
        self.startDate = gqlAdvertisement.advertisement.startdate
        self.endDate = gqlAdvertisement.advertisement.enddate
        self.adOwner = adOwner
    }

    public init?(gqlAdvertisement: GetAdsHistoryListQuery.Data.AdvertisementHistory.AffectedRows.Advertisement) {
        guard
            let adOwner = RowUser(gqlUser: gqlAdvertisement.user)
        else {
            return nil
        }

        self.id = gqlAdvertisement.id
        self.adType = .pinned
        self.creationDate = gqlAdvertisement.createdAt
        self.startDate = gqlAdvertisement.timeframeStart
        self.endDate = gqlAdvertisement.timeframeEnd
        self.adOwner = adOwner
    }
}
