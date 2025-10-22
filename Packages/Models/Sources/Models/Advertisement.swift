//
//  Advertisement.swift
//  Models
//
//  Created by Artem Vasin on 14.10.25.
//

import Foundation
import GQLOperationsUser

public enum AdType {
    case pinned
}

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
}
