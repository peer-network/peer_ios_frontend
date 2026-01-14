//
//  CheckoutAmount.swift
//  PeerApp
//
//  Created by Artem Vasin on 12.01.26.
//

import Environment
import Foundation

struct CheckoutAmount {
    let tokenomics: ConstantsConfig.Tokenomics
    let baseAmount: Decimal
    let areFeesIncluded: Bool
    let hasInviter: Bool

    let maxFractionDigits = 10

    private var peerRate: Decimal { Decimal(tokenomics.fees.peer) }
    private var burnRate: Decimal { Decimal(tokenomics.fees.burn) }
    private var inviterRate: Decimal { Decimal(tokenomics.fees.invitation) }

    var peerFee: (percent: Int, amount: Decimal) {
        let a = rounded(baseAmount * peerRate, scale: maxFractionDigits)
        return (percentInt(from: peerRate), a)
    }

    var burnFee: (percent: Int, amount: Decimal) {
        let a = rounded(baseAmount * burnRate, scale: maxFractionDigits)
        return (percentInt(from: burnRate), a)
    }

    var inviterFee: (percent: Int, amount: Decimal) {
        let a = rounded(baseAmount * inviterRate, scale: maxFractionDigits)
        return (percentInt(from: inviterRate), a)
    }

    var totalFeeRate: Decimal {
        peerRate + burnRate + (hasInviter ? inviterRate : 0)
    }

    var totalFee: (percent: Int, amount: Decimal) {
        let a = rounded(baseAmount * totalFeeRate, scale: maxFractionDigits)
        return (percentInt(from: totalFeeRate), a)
    }

    var finalTotalAmount: Decimal {
        rounded(baseAmount + (areFeesIncluded ? 0 : totalFee.amount), scale: maxFractionDigits)
    }

    // MARK: helpers

    private func rounded(_ value: Decimal, scale: Int) -> Decimal {
        var v = value
        var result = Decimal()
        NSDecimalRound(&result, &v, scale, .plain)
        return result
    }

    private func percentInt(from rate: Decimal) -> Int {
        let p = rounded(rate * 100, scale: 0)
        return NSDecimalNumber(decimal: p).intValue
    }
}
