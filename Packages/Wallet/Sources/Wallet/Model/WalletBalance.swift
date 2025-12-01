//
//  WalletBalance.swift
//  Wallet
//
//  Created by Artem Vasin on 25.04.25.
//

import Foundation

struct WalletBalance {
    let amount: Decimal
    let tokenPrice: Decimal

    var balanceEUR: Decimal {
        amount * tokenPrice
    }
}

extension WalletBalance {
    static let placeholder = WalletBalance(amount: 8000, tokenPrice: 0.1)
}
