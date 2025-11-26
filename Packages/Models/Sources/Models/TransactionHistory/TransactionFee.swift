//
//  TransactionFee.swift
//  Models
//
//  Created by Artem Vasin on 26.11.25.
//

import Foundation

public struct TransactionFee: Hashable {
    public let total: Decimal
    public let burn: Decimal
    public let peer: Decimal
    public let inviter: Decimal
}
