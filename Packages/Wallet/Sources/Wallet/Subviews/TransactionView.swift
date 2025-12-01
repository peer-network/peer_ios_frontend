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

    @State private var expanded: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            typeView

            titleView
                .frame(maxWidth: .infinity, alignment: .leading)

            amountView
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    @ViewBuilder
    private var titleView: some View {
        let spacing: CGFloat = transaction.message == nil ? 2 : 0

        VStack(alignment: .leading, spacing: spacing) {
            Text("Title here")
                .appFont(.bodyBold)
                .foregroundStyle(Colors.whitePrimary)

            Text(transaction.createdAt)
                .appFont(.smallLabelRegular)

            if let message = transaction.message {
                Text(message)
                    .appFont(.smallLabelBold)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .foregroundStyle(Colors.whiteSecondary)
    }

    private var typeView: some View {
        Circle()
            .frame(width: 55)
            .foregroundStyle(Colors.blackDark)
            .overlay {
                typeIcon
            }
            .overlay(alignment: .bottomTrailing) {
                arrowIcon
            }
    }

    @ViewBuilder
    private var typeIcon: some View {
        switch transaction.type {
            case .extraPost:
                Icons.camera
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .extraLike:
                Icons.heartFill
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.redAccent)
            case .extraComment:
                Icons.bubbleFill
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .dislike:
                Icons.heartBrokeFill
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.redAccent)
            case .transferTo, .transferFrom:
                ProfileAvatarView(
                    url: transaction.recipient.imageURL,
                    name: transaction.recipient.username,
                    config: .transactionHistory,
                    ignoreCache: true
                )
            case .pinPost:
                Icons.pin
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .referralReward:
                IconsNew.referral
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .dailyMint:
                IconsNew.clockAndMoney
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
        }
    }

    @ViewBuilder
    private var arrowIcon: some View {
        switch transaction.type {
            case .extraPost, .extraLike, .extraComment, .dislike, .transferTo, .pinPost:
                Circle()
                    .frame(height: 20)
                    .foregroundStyle(Colors.hashtag)
                    .overlay {
                        IconsNew.arrowRight
                            .iconSize(height: 7)
                            .foregroundStyle(Colors.whitePrimary)
                    }
            case .transferFrom, .referralReward, .dailyMint:
                Circle()
                    .frame(height: 20)
                    .foregroundStyle(Colors.hashtag)
                    .overlay {
                        IconsNew.arrowRight
                            .iconSize(height: 7)
                            .foregroundStyle(Colors.whitePrimary)
                            .rotationEffect(.degrees(180))
                    }
        }
    }

    private var amountView: some View {
        HStack(spacing: 5) {
            Text(transaction.tokenAmount.formatted(.number))
                .appFont(.bodyBold)

            Icons.logoCircleWhite
                .iconSize(height: 16.5)

            Icons.arrowDown
                .iconSize(height: 8)
                .rotationEffect(.degrees(expanded ? 180 : 270))
                .animation(.easeInOut, value: expanded)
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}
