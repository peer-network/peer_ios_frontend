//
//  TransferSummaryView.swift
//  Wallet
//
//  Created by Artem Vasin on 22.12.25.
//

import SwiftUI
import DesignSystem
import Models
import Foundation

public struct TransferSummaryView: View {
    private let balance: Foundation.Decimal
    private let recipient: RowUser
    private let amount: Foundation.Decimal
    private let message: String?
    private let onClose: () -> Void
    private let onSubmit: () -> Void

    public init(balance: Foundation.Decimal, recipient: RowUser, amount: Foundation.Decimal, message: String?, onClose: @escaping () -> Void, onSubmit: @escaping () -> Void) {
        self.balance = balance
        self.recipient = recipient
        self.amount = amount
        self.message = message
        self.onClose = onClose
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Transfer")
        } content: {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 10) {
                        balanceView

                        recipientView(recipient: recipient)
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(Colors.inactiveDark)
                            }

                        if let message {
                            messageView(text: message)
                                .padding(20)
                                .background {
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(Colors.inactiveDark)
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var balanceView: some View {
        VStack(spacing: 10) {
            Text("Remaining balance")
                .appFont(.smallLabelRegular)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                Text("\(balance)")
                    .appFont(.extraLargeTitleBold)
                    .minimumScaleFactor(0.5)
                    .truncationMode(.tail)
                    .lineLimit(1)

                Icons.logoCircleWhite
                    .iconSize(height: 27)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .padding(20)
        .background {
            Colors.whitePrimary.opacity(0.2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func recipientView(recipient: RowUser) -> some View {
        HStack(spacing: 0) {
            Text("Sending to")
                .appFont(.smallLabelBold)
                .foregroundStyle(Colors.whitePrimary)

            Spacer(minLength: 5)

            Text("@\(recipient.username)")
                .appFont(.smallLabelBoldItalic)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.trailing, 2)

            Text("#\(String(recipient.slug))")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)
        }
        .lineLimit(1)
    }

    private func transferAmountView() -> some View {
        Text("123213")
    }

    private func messageView(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                IconsNew.bubbleLines
                    .iconSize(height: 15)

                Text("Message")
                    .appFont(.smallLabelBold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Capsule()
                .frame(height: 1)
                .foregroundStyle(Colors.whiteSecondary)

            Text(text)
                .appFont(.smallLabelRegular)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}
