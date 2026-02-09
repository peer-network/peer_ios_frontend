//
//  TransferVM.swift
//  Wallet
//
//  Created by Artem Vasin on 21.12.25.
//

import Combine
import Foundation
import Environment
import Models

@MainActor
final class TransferVM: ObservableObject {
    @Published var recipient: RowUser? = nil
    @Published var amount: Foundation.Decimal? = nil
    @Published var fees: TransferFeesModel? = nil
    @Published var message: String? = nil

    let currentBalance: Foundation.Decimal

    var canDoTransfer: Bool {
        guard let fees else { return false }

        return !(recipient == nil || amount == nil || fees.totalWithFees > currentBalance)
    }

    init(balance: Foundation.Decimal) {
        self.currentBalance = balance
    }
}
