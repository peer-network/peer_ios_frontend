//
//  TransactionView.swift
//  Wallet
//
//  Created by Artem Vasin on 26.11.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment

struct TransactionView: View {
    @Environment(\.redactionReasons) private var reasons

    @EnvironmentObject private var appState: AppState

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
        .geometryGroup()
    }

    @ViewBuilder
    private var titleView: some View {
        let spacing: CGFloat = transaction.message == nil ? 2 : 0

        VStack(alignment: .leading, spacing: spacing) {
            titleTextView
                .appFont(.bodyBold)
                .foregroundStyle(Colors.whitePrimary)

            Text(convertUTCToLocalDate(transaction.createdAt) ?? "Undefined date")
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
            case .transferTo:
                Group {
                    if transaction.recipient.visibilityStatus == .illegal {
                        Circle()
                            .foregroundStyle(Colors.blackDark)
                            .frame(height: 55)
                            .overlay {
                                IconsNew.exclamaitionMarkCircle
                                    .iconSize(height: 30)
                                    .foregroundStyle(Colors.whiteSecondary)
                            }
                    } else {
                        ProfileAvatarView(
                            url: transaction.recipient.imageURL,
                            name: transaction.recipient.username,
                            config: .transactionHistory,
                            ignoreCache: true
                        )
                        .ifCondition(transaction.recipient.visibilityStatus == .hidden) {
                            $0
                                .blur(radius: 4)
                                .overlay {
                                    IconsNew.eyeWithSlash
                                        .iconSize(width: 24)
                                        .foregroundStyle(Colors.whitePrimary)
                                }
                        }
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    }
                }
            case .transferFrom:
                Group {
                    if transaction.sender.visibilityStatus == .illegal {
                        Circle()
                            .foregroundStyle(Colors.blackDark)
                            .frame(height: 55)
                            .overlay {
                                IconsNew.exclamaitionMarkCircle
                                    .iconSize(height: 30)
                                    .foregroundStyle(Colors.whiteSecondary)
                            }
                    } else {
                            ProfileAvatarView(
                                url: transaction.sender.imageURL,
                                name: transaction.sender.username,
                                config: .transactionHistory,
                                ignoreCache: true
                            )
                            .ifCondition(transaction.sender.visibilityStatus == .hidden) {
                                $0
                                    .blur(radius: 4)
                                    .overlay {
                                        IconsNew.eyeWithSlash
                                            .iconSize(width: 24)
                                            .foregroundStyle(Colors.whitePrimary)
                                    }
                            }
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                    }
                }
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
        if isAmountPositive() {
            Circle()
                .frame(height: 20)
                .foregroundStyle(Colors.hashtag)
                .overlay {
                    IconsNew.arrowRight
                        .iconSize(height: 7)
                        .foregroundStyle(Colors.whitePrimary)
                        .rotationEffect(.degrees(180))
                }
        } else {
            Circle()
                .frame(height: 20)
                .foregroundStyle(Colors.hashtag)
                .overlay {
                    IconsNew.arrowRight
                        .iconSize(height: 7)
                        .foregroundStyle(Colors.whitePrimary)
                }
        }
    }

    private var amountView: some View {
        HStack(spacing: 5) {
            let amountPrefix = isAmountPositive() ? "+" : ""

            Text(amountPrefix + "\(formatDecimal(transaction.tokenAmount))")
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
                textAmountLine(text: "\(Int(appState.getConstants()!.data.tokenomics.fees.peer * 100))% to Peer Bank (platform fee)", amount: peer)
            }

            if let burn = fees.burn {
                textAmountLine(text: "\(Int(appState.getConstants()!.data.tokenomics.fees.burn * 100))% Burned (removed from supply)", amount: burn)
            }

            if let inviter = fees.inviter {
                textAmountLine(text: "\(Int(appState.getConstants()!.data.tokenomics.fees.invitation * 100))% to your Inviter", amount: inviter)
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
                Text(formatDecimal(abs(amount)))
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
        transaction.tokenAmount > 0 ? true : false
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
                AnyView(HStack(spacing: 1.57) {
                    let username = transaction.recipient.visibilityStatus == .hidden ? "hidden" : transaction.recipient.username
                    Text("To ***@\(username)***").appFont(.bodyBold)
                    Text("#\(String(transaction.recipient.slug))").foregroundStyle(Colors.whiteSecondary).appFont(.bodyRegular)
                })
            case .transferFrom:
                AnyView(HStack(spacing: 1.57) {
                    let username = transaction.sender.visibilityStatus == .hidden ? "hidden" : transaction.sender.username
                    Text("From ***@\(username)***").appFont(.bodyBold)
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

    private func convertUTCToLocalDate(_ utcDateString: String) -> String? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        guard let date = dateFormatter.date(from: utcDateString) else {
            return nil
        }

        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: date)
    }

    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = TransferAmountFormatters.numberFormatter
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 10
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}
