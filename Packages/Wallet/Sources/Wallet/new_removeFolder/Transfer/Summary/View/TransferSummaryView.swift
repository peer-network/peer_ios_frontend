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
    @EnvironmentObject private var appState: AppState

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
                        Text("Summary")
                            .appFont(.largeTitleRegular)
                            .foregroundStyle(Colors.whitePrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        balanceView

                        recipientView(recipient: transferSummaryVM.recipient)
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(Colors.inactiveDark)
                            }

                        transferAmountView()
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
                    .padding(.top, -10)
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
            Text("Available balance")
                .appFont(.smallLabelRegular)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                Text("\(formatDecimal(transferSummaryVM.currentBalance))")
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
                .appFont(.bodyBoldItalic)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.trailing, 2)

            Text("#\(String(recipient.slug))")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whiteSecondary)
        }
        .lineLimit(1)
    }

    private func transferAmountView() -> some View {
        let model = TransferFeesModel(
            amount: transferSummaryVM.amount,
            tokenomics: appState.getConstants()!.data.tokenomics,
            hasInviter: AccountManager.shared.inviter != nil,
            maxFractionDigits: 10
        )

        return VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text("Total amount")
                    .appFont(.smallLabelBold)

                Spacer(minLength: 5)
                    .layoutPriority(-1)

                HStack(spacing: 5) {
                    Text(formatDecimal(model.totalWithFees))
                        .appFont(.largeTitleBold)
                        .numericTextIfAvailable()

                    Icons.logoCircleWhite
                        .iconSize(height: 15)
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(Colors.blackDark)
            }

            TransferFeesView(model: model)
        }
        .lineLimit(1)
    }

    private func formatDecimal(_ value: Decimal) -> String {
        let f = TransferAmountFormatters.numberFormatter
        f.locale = Locale.current
        f.maximumFractionDigits = 10
        return f.string(from: value as NSDecimalNumber) ?? "\(value)"
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
