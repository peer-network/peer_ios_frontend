//
//  ReferralInfo.swift
//  Models
//
//  Created by Artem Vasin on 26.05.25.
//

import GQLOperationsUser

public struct ReferralInfo {
    public let referralUuid: String
    public let referralLink: String

    public init?(gqlData: GetMyReferralInfoQuery.Data.GetReferralInfo) {
        guard
            let referralUuid = gqlData.referralUuid,
            let referralLink = gqlData.referralLink
        else {
            return nil
        }

        self.referralUuid = referralUuid
        self.referralLink = referralLink
    }
}
