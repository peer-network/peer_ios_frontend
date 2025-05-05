//
//  TransferPageViewModel.swift
//  Wallet
//
//  Created by Artem Vasin on 05.05.25.
//

import SwiftUI
import Models

@MainActor
final class TransferPageViewModel: ObservableObject {
    let recipient: RowUser
    let amount: Int

    enum ScreenState {
        case confirmation
        case approving
        case done
    }
    @Published private(set) var screenState: ScreenState = .confirmation

    init(recipient: RowUser, amount: Int) {
        self.recipient = recipient
        self.amount = amount
    }

    func completeTransfer() {
        screenState = .approving
        Task {
            try? await Task.sleep(for: .seconds(5))
            withAnimation(.easeInOut(duration: 0.2)) {
                screenState = .done
            }
        }
    }
}
