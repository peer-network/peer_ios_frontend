//
//  Transaction.swift
//  Models
//
//  Created by Artem Vasin on 26.11.25.
//

import Foundation
import GQLOperationsUser

public struct Transaction: Identifiable, Hashable {

    public enum TransactionType {
        case extraPost
        case extraLike
        case extraComment
        case dislike
        case transferTo
        case transferFrom
        case pinPost
        case referralReward
        case dailyMint
    }

    public let id: String
    public let type: TransactionType
    public let tokenAmount: Foundation.Decimal
    public let netTokenAmount: Foundation.Decimal
    public let message: String?
    public let createdAt: String
    public let sender: RowUser
    public let recipient: RowUser
    public let fees: TransactionFee?

    public init?(gqlTransaction: GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow) {
        guard
            let sender = RowUser(gqlUser: gqlTransaction.sender),
            let recipient = RowUser(gqlUser: gqlTransaction.recipient)
        else {
            return nil
        }

        self.id = gqlTransaction.operationid
        self.type = .dislike
        self.tokenAmount = gqlTransaction.tokenamount
        self.netTokenAmount = gqlTransaction.netTokenAmount
        self.message = gqlTransaction.message
        self.createdAt = gqlTransaction.createdat
        self.sender = sender
        self.recipient = recipient
        self.fees = gqlTransaction.fees == nil ? nil : .init(gqlFee: gqlTransaction.fees!)
    }
}
