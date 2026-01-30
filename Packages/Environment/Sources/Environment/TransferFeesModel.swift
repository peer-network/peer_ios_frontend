//
//  TransferFeesModel.swift
//  Models
//
//  Created by Artem Vasin on 15.01.26.
//

import Foundation

public struct TransferFeesModel {
    public let amount: Decimal
    public let tokenomics: ConstantsConfig.Tokenomics
    public let hasInviter: Bool
    public let maxFractionDigits: Int

    public var peerRate: Decimal { Decimal(tokenomics.fees.peer) }
    public var burnRate: Decimal { Decimal(tokenomics.fees.burn) }
    public var inviterRate: Decimal { Decimal(tokenomics.fees.invitation) }

    public init(amount: Decimal, tokenomics: ConstantsConfig.Tokenomics, hasInviter: Bool, maxFractionDigits: Int) {
        self.amount = amount
        self.tokenomics = tokenomics
        self.hasInviter = hasInviter
        self.maxFractionDigits = maxFractionDigits
    }

    public var peerFee: (percent: Int, amount: Decimal) {
        let a = rounded(amount * peerRate, scale: maxFractionDigits)
        return (percentInt(from: peerRate), a)
    }

    public var burnFee: (percent: Int, amount: Decimal) {
        let a = rounded(amount * burnRate, scale: maxFractionDigits)
        return (percentInt(from: burnRate), a)
    }

    public var inviterFee: (percent: Int, amount: Decimal) {
        let a = rounded(amount * inviterRate, scale: maxFractionDigits)
        return (percentInt(from: inviterRate), a)
    }

    public var totalFeeRate: Decimal {
        peerRate + burnRate + (hasInviter ? inviterRate : 0)
    }

    public var totalFee: (percent: Int, amount: Decimal) {
        let a = rounded(amount * totalFeeRate, scale: maxFractionDigits)
        return (percentInt(from: totalFeeRate), a)
    }

    public var totalWithFees: Decimal {
        rounded(amount + totalFee.amount, scale: maxFractionDigits)
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

extension TransferFeesModel: Equatable {
    public static func == (lhs: TransferFeesModel, rhs: TransferFeesModel) -> Bool {
        lhs.amount == rhs.amount
    }
}

extension TransferFeesModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        amount.hash(into: &hasher)
    }
}
