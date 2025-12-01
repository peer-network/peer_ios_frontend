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

    public init?(gqlFee: GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Fees) {
        self.total = gqlFee.total
        self.burn = gqlFee.burn
        self.peer = gqlFee.peer
        self.inviter = gqlFee.inviter
    }
}
