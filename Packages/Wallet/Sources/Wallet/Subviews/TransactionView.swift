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
    @Environment(\.redactionReasons) private var reasons

    let transaction: Models.Transaction

    @State private var expanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                expanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    typeView

                    titleView
                        .frame(maxWidth: .infinity, alignment: .leading)

                    amountView
                }

                if let fees = transaction.fees {
                    if expanded {
                        expandedView(fees: fees)
                            .foregroundStyle(Colors.whiteSecondary)
                    }
                }
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(Colors.inactiveDark)
            }
            .clipShape( RoundedRectangle(cornerRadius: 24))
            .contentShape(.rect)
        }
        .ifCondition(reasons.contains(.placeholder)) {
            $0
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(Colors.inactiveDark)
                }
        }
    }

    @ViewBuilder
    private var titleView: some View {
        let spacing: CGFloat = transaction.message == nil ? 2 : 0

        VStack(alignment: .leading, spacing: spacing) {
            titleTextView
                .appFont(.bodyBold)
                .foregroundStyle(Colors.whitePrimary)

            Text(transaction.createdAt)
                .appFont(.smallLabelRegular)

            if
                transaction.type == .transferTo || transaction.type == .transferFrom,
                let message = transaction.message,
                !message.isEmpty
            {
                Text(message)
                    .appFont(.smallLabelBold)
            }
        }
        .lineLimit(1)
        .truncationMode(.tail)
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
                ) // TODO: Add illegal and blured overlays
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
            case .shop:
                IconsNew.shop
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            case .unknown:
                IconsNew.exclamaitionMarkCircle
                    .iconSize(height: 24)
                    .foregroundStyle(Colors.whitePrimary)
        }
    }

    @ViewBuilder
    private var arrowIcon: some View {
        switch transaction.type {
            case .extraPost, .extraLike, .extraComment, .dislike, .transferTo, .pinPost, .shop, .unknown:
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
            let amountPrefix = isAmountPositive() ? "+" : "-"

            Text(amountPrefix + "\(transaction.tokenAmount.formatted(.number))")
                .appFont(.bodyBold)

            Icons.logoCircleWhite
                .iconSize(height: 16.5)

            Icons.arrowDown
                .iconSize(height: 8)
                .rotationEffect(.degrees(expanded ? 180 : 270))
                .animation(.easeInOut, value: expanded)
        }
        .foregroundStyle(Colors.whitePrimary)
        .lineLimit(1)
    }

    @ViewBuilder
    private func expandedView(fees: TransactionFee) -> some View {
        Capsule()
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Colors.whiteSecondary)

        Group {
            textAmountLine(text: "Transaction amount", amount: transaction.tokenAmount, amountIsBold: true)

            textAmountLine(text: "Base amount", amount: transaction.netTokenAmount, amountIsBold: true)

            if let total = fees.total {
                textAmountLine(text: "Fees included", amount: total, amountIsBold: true)
            }
        }
        .appFont(.bodyRegular)
        .foregroundStyle(Colors.whitePrimary)

        Group {
            if let peer = fees.peer {
                textAmountLine(text: "2% to Peer Bank (platform fee)", amount: peer) // TODO: Take % from Constants
            }

            if let burn = fees.burn {
                textAmountLine(text: "1% Burned (removed from supply)", amount: burn) // TODO: Take % from Constants
            }

            if let inviter = fees.inviter {
                textAmountLine(text: "1% to your Inviter", amount: inviter) // TODO: Take % from Constants
            }
        }
        .appFont(.smallLabelRegular)

        if
            transaction.type == .transferTo || transaction.type == .transferFrom,
            let message = transaction.message,
            !message.isEmpty
        {
            Text("Message:")
                .appFont(.bodyRegular)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(message)
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.blackDark)
                }
        }
    }

    @ViewBuilder
    private func textAmountLine(text: String, amount: Decimal, amountIsBold: Bool = false) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Text(amount, format: .number)
                    .bold(amountIsBold)

                Icons.logoCircleWhite
                    .iconSize(height: 12.83)
                    .opacity(amountIsBold ? 1 : 0.5)
            }
        }
        .lineLimit(1)
        .truncationMode(.tail)
    }

    private func isAmountPositive() -> Bool {
        switch transaction.type {
            case .extraPost, .extraLike, .extraComment, .dislike, .transferTo, .pinPost, .shop:
                return false
            case .transferFrom, .referralReward, .dailyMint, .unknown:
                return true
        }
    }

    private var titleTextView: some View {
        switch transaction.type {
            case .extraPost:
                AnyView(Text("Extra post"))
            case .extraLike:
                AnyView(Text("Extra like"))
            case .extraComment:
                AnyView(Text("Extra comment"))
            case .dislike:
                AnyView(Text("Dislike"))
            case .transferTo:
                AnyView(HStack(spacing: 0) {
                    Text("To ***@\(transaction.recipient.username)***").appFont(.bodyBold)
                    Text("#\(String(transaction.recipient.slug))").foregroundStyle(Colors.whiteSecondary).appFont(.bodyRegular)
                })
            case .transferFrom:
                AnyView(HStack(spacing: 0) {
                    Text("From ***@\(transaction.sender.username)***").appFont(.bodyBold)
                    Text("#\(String(transaction.sender.slug))").foregroundStyle(Colors.whiteSecondary).appFont(.bodyRegular)
                })
            case .pinPost:
                AnyView(Text("Pinned post promo"))
            case .referralReward:
                AnyView(Text("Referral reward"))
            case .shop:
                AnyView(Text("Peer Shop"))
            case .dailyMint:
                AnyView(Text("Daily Mint"))
            case .unknown:
                AnyView(Text("Unknown"))
        }
    }
}
