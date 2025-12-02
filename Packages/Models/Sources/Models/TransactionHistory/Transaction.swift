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

    public init(
        id: String,
        type: TransactionType,
        tokenAmount: Decimal,
        netTokenAmount: Decimal,
        message: String?,
        createdAt: String,
        sender: RowUser,
        recipient: RowUser,
        fees: TransactionFee?
    ) {
        self.id = id
        self.type = type
        self.tokenAmount = tokenAmount
        self.netTokenAmount = netTokenAmount
        self.message = message
        self.createdAt = createdAt
        self.sender = sender
        self.recipient = recipient
        self.fees = fees
    }

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

extension Transaction {
    public static func placeholders(count: Int = 10) -> [Transaction] {
        return (0..<count).map { _ in
            Transaction(
                id: UUID().uuidString,
                type: .dislike,
                tokenAmount: 100,
                netTokenAmount: 100,
                message: "Placeholder message",
                createdAt: "10 Jun 2025, 04:20",
                sender: .placeholders(count: 1).first!,
                recipient: .placeholders(count: 1).first!,
                fees: .placeholder()
            )
        }
    }
}
