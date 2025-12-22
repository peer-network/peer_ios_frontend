//
//  TransferSummaryView.swift
//  Wallet
//
//  Created by Artem Vasin on 22.12.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models
import Foundation

public struct TransferSummaryView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var transferSummaryVM: TransferSummaryVM

    public init(balance: Foundation.Decimal, recipient: RowUser, amount: Foundation.Decimal, message: String?) {
        _transferSummaryVM = .init(wrappedValue: .init(currentBalance: balance, recipient: recipient, amount: amount, message: message))
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Transfer")
        } content: {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 10) {
                        balanceView

                        recipientView(recipient: transferSummaryVM.recipient)
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(Colors.inactiveDark)
                            }

                        if let message = transferSummaryVM.message {
                            messageView(text: message)
                                .padding(20)
                                .background {
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundStyle(Colors.inactiveDark)
                                }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, ButtonSize.small.height + 20)
                }
                .scrollIndicators(.hidden)

                HStack(spacing: 10) {
                    let btnConfig1 = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Back")
                    StateButton(config: btnConfig1) {
                        router.path.removeLast()
                    }

                    let btnConfig2 = StateButtonConfig(buttonSize: .small, buttonType: .primary, title: "Submit transfer")
                    AsyncStateButton(config: btnConfig2) {
                        await transferSummaryVM.send()
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.keyboard)
            }
        }
        .onFirstAppear {
            transferSummaryVM.apiService = apiManager.apiService
            transferSummaryVM.popupService = SystemPopupManager.shared
            transferSummaryVM.onTransferCompleted = {
                self.router.emptyPath()
            }
        }
    }

    private var balanceView: some View {
        VStack(spacing: 10) {
            Text("Remaining balance")
                .appFont(.smallLabelRegular)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                Text("\(transferSummaryVM.currentBalance)")
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
