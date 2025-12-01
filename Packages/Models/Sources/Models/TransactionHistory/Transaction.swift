//
//  Transaction.swift
//  Models
//
//  Created by Artem Vasin on 26.11.25.
//

import Foundation

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
    public let tokenAmount: Decimal
    public let netTokenAmount: Decimal
    public let message: String?
    public let createdAt: String
    public let sender: RowUser
    public let recipient: RowUser
    public let fees: TransactionFee
}
