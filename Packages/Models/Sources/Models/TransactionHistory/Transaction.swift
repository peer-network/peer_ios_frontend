//
//  Transaction.swift
//  Models
//
//  Created by Artem Vasin on 26.11.25.
//

import Foundation

public struct Transaction: Identifiable, Hashable {
    public let id: String
    public let type: String
    public let tokenAmount: Decimal
    public let netTokenAmount: Decimal
    public let message: String?
    public let createdAt: String
    public let sender: RowUser
    public let recipient: RowUser
    public let fees: TransactionFee
}
