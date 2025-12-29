//
//  TransactionFee.swift
//  Models
//
//  Created by Artem Vasin on 26.11.25.
//

import Foundation
import GQLOperationsUser

public struct TransactionFee: Hashable {
    public let total: Foundation.Decimal?
    public let burn: Foundation.Decimal?
    public let peer: Foundation.Decimal?
    public let inviter: Foundation.Decimal?

    public init(
        total: Foundation.Decimal?,
        burn: Foundation.Decimal?,
        peer: Foundation.Decimal?,
        inviter: Foundation.Decimal?
    ) {
        self.total = total
        self.burn = burn
        self.peer = peer
        self.inviter = inviter
    }

    public init?(gqlFee: GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Fees) {
        self.total = gqlFee.total
        self.burn = gqlFee.burn
        self.peer = gqlFee.peer
        self.inviter = gqlFee.inviter
    }
}

public extension TransactionFee {
    static func placeholder() -> TransactionFee {
        TransactionFee(
            total: 10,
            burn: 5,
            peer: 3,
            inviter: 2
        )
    }
}
