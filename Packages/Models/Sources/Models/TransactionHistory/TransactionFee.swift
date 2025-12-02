//
//  TransactionFee.swift
//  Models
//
//  Created by Artem Vasin on 26.11.25.
//

import Foundation
import GQLOperationsUser

public struct TransactionFee: Hashable {
    public let total: Decimal?
    public let burn: Decimal?
    public let peer: Decimal?
    public let inviter: Decimal?

    public init(
        total: Decimal?,
        burn: Decimal?,
        peer: Decimal?,
        inviter: Decimal?
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
