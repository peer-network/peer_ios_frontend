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
    unowned var apiService: APIService!
    unowned var popupService: (any SystemPopupManaging)!

    @Published var recipient: RowUser? = nil
    @Published var amount: Foundation.Decimal? = nil
    @Published var message: String? = nil

    let currentBalance: Foundation.Decimal
    let onTransferCompleted: () -> Void

    var canDoTransfer: Bool {
        !(recipient == nil || amount == nil)
    }

    init(balance: Foundation.Decimal, onTransferCompleted: @escaping () -> Void) {
        self.currentBalance = balance
        self.onTransferCompleted = onTransferCompleted
    }

    func send() async {
        guard
            let userId = recipient?.id,
            let amount = amount
        else {
            return
        }

        let result = await apiService.transferTokens(to: userId, amount: amount, message: message)

        switch result {
            case .success:
                popupService.presentPopup(.transferSuccess) {
                    self.onTransferCompleted()
                }
            case .failure(let apiError):
                popupService.presentPopup(.error(text: apiError.userFriendlyMessage)) {
                    //
                }
        }
    }
}
