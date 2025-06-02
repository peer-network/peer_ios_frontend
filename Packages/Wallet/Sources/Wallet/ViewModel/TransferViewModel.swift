//
//  TransferViewModel.swift
//  Wallet
//
//  Created by Artem Vasin on 02.05.25.
//

import SwiftUI
import Models
import Environment

@MainActor
final class TransferViewModel: ObservableObject {
    enum ScreenState {
        case main
        case inputAmount
    }
    @Published private(set) var screenState: ScreenState = .main

    @Published private(set) var recipient: RowUser?

    var feePercents: String {
        if AccountManager.shared.inviter != nil {
            return "5"
        } else {
            return "4"
        }
    }

    func setRecipient(_ recipient: RowUser) {
        self.recipient = recipient
        screenState = .inputAmount
    }

    func resetProcess() {
        screenState = .main
        recipient = nil
    }
}
