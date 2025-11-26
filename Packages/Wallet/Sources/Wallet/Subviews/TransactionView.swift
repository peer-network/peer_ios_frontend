//
//  TransactionView.swift
//  Wallet
//
//  Created by Artem Vasin on 26.11.25.
//

import SwiftUI
import DesignSystem
import Models

struct TransactionView: View {
    let transaction: Models.Transaction

    var body: some View {
        HStack(alignment: .center, spacing: 10) {

        }
    }

    private var icon: some View {
        switch transaction.type {
            case .extraPost:
                return Icons.camera
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .extraLike:
                return Icons.heartFill
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.redAccent)
            case .extraComment:
                return Icons.bubbleFill
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .dislike:
                return Icons.heartBrokeFill
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.redAccent)
            case .transfer:
                return Icons.heartBrokeFill // TODO: Hidden, illegal, etc
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.redAccent)
            case .pinPost:
                return Icons.pin
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .referralReward:
                return IconsNew.referral
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .dailyMint:
                return IconsNew.clockAndMoney
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
        }
    }
}
