//
//  TransferSummaryVM.swift
//  Wallet
//
//  Created by Artem Vasin on 22.12.25.
//

import Combine
import Foundation
import Environment
import Models

@MainActor
final class TransferSummaryVM: ObservableObject {
    unowned var apiService: APIService!
    unowned var popupService: (any SystemPopupManaging)!

    let currentBalance: Foundation.Decimal
    let recipient: RowUser
    let amount: Foundation.Decimal
    let message: String?
    var onTransferCompleted: (() -> Void)?

    init(currentBalance: Foundation.Decimal, recipient: RowUser, amount: Foundation.Decimal, message: String?) {
        self.currentBalance = currentBalance
        self.recipient = recipient
        self.amount = amount
        self.message = message
    }

    func send() async {
        let result = await apiService.transferTokens(to: recipient.id, amount: amount, message: message)

        switch result {
            case .success:
                popupService.presentPopup(.transferSuccess) {
                    self.onTransferCompleted?()
                }
            case .failure(let apiError):
                popupService.presentPopup(.error(text: apiError.userFriendlyMessage)) {
                    Task {
                        await self.send()
                    }
                }
        }
    }
}
