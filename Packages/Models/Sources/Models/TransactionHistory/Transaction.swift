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
        case shop
        case dailyMint
        case unknown

        public static func normalizedValue(from apiValue: TransactionCategory, amount: Foundation.Decimal) -> TransactionType {
            switch apiValue {
                case .p2PTransfer:
                    if amount >= 0 {
                        return .transferFrom
                    } else {
                        return .transferTo
                    }
                case .adPinned:
                    return .pinPost
                case .postCreate:
                    return .extraPost
                case .like:
                    return .extraLike
                case .dislike:
                    return .dislike
                case .comment:
                    return .extraComment
                case .tokenMint:
                    return .dailyMint
                case .shopPurchase:
                    return .shop
            }
        }
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
        tokenAmount: Foundation.Decimal,
        netTokenAmount: Foundation.Decimal,
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
        if let gqlType = gqlTransaction.transactionCategory?.value {
            self.type = TransactionType.normalizedValue(from: gqlType, amount: gqlTransaction.netTokenAmount)
        } else {
            self.type = .unknown
        }
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
