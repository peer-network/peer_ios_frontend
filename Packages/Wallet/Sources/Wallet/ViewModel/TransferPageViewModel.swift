//
//  TransferPageViewModel.swift
//  Wallet
//
//  Created by Artem Vasin on 05.05.25.
//

import SwiftUI
import Models
import Environment

@MainActor
final class TransferPageViewModel: ObservableObject {
    public unowned var apiService: APIService!
    
    let recipient: RowUser
    let amount: Int

    enum ScreenState {
        case confirmation
        case approving
        case done
        case failed(error: APIError)
    }

    @Published private(set) var screenState: ScreenState = .confirmation

    init(recipient: RowUser, amount: Int) {
        self.recipient = recipient
        self.amount = amount
    }

    var amountWithFee: Double {
        Double(amount) + feeAmount
    }

    var feeAmount: Double {
        if AccountManager.shared.inviter != nil {
            return Double(amount) * 0.05
        } else {
            return Double(amount) * 0.04
        }
    }

    func completeTransfer() {
        screenState = .approving
        Task { [weak self] in
            guard let self else { return }

            let result = await apiService.transferTokens(to: recipient.id, amount: amount)

            switch result {
                case .success:
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.screenState = .done
                    }
                case .failure(let error):
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.screenState = .failed(error: error)
                    }
            }
        }
    }
}
