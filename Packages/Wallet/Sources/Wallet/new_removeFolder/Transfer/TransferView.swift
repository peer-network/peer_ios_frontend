//
//  TransferView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import Foundation
import Environment
import DesignSystem

public struct TransferView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @frozen
    public enum FocusField {
        case recipientSearch
        case amount
        case message
    }

    @State private var focusedField: FocusField?

    @StateObject private var transferVM: TransferVM

    public init(balance: Foundation.Decimal, onTransferCompleted: @escaping () -> Void) {
        _transferVM = .init(wrappedValue: .init(balance: balance, onTransferCompleted: onTransferCompleted))
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Transfer")
        } content: {
            ZStack(alignment: .bottom) {
                ScrollView {
                    content
                        .padding(20)
                        .padding(.bottom, ButtonSize.large.height + 20)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)

                let btnConfig = StateButtonConfig(buttonSize: .small, buttonType: .secondary, title: "Continue")
                AsyncStateButton(config: btnConfig) {
                    await transferVM.send()
                }
                .disabled(!transferVM.canDoTransfer)
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
            transferVM.apiService = apiManager.apiService
            transferVM.popupService = SystemPopupManager.shared
        }
    }

    private var content: some View {
        VStack(spacing: 10) {
            balanceView

            TransferRecipientPickerView(focusState: $focusedField, focusEquals: .recipientSearch) { user in
                transferVM.recipient = user
            }

            TransferAmountView(focusState: $focusedField, focusEquals: .amount, balance: transferVM.currentBalance) { amount in
                transferVM.amount = amount
            }

            TransferMessageView(focusState: $focusedField, focusEquals: .message) {
                //
            }
        }
    }

    private var balanceView: some View {
        VStack(spacing: 10) {
            Text("Available balance")
                .appFont(.smallLabelRegular)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                Text("\(transferVM.currentBalance)")
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
            ZStack {
                Ellipse()
                    .fill(Gradients.walletBG1)
                    .frame(width: 265, height: 220)
                    .padding(.bottom, 54)
                    .padding(.leading, 306)
                    .blur(radius: 10)

                Ellipse()
                    .fill(Gradients.walletBG2)
                    .frame(width: 479, height: 208)
                    .padding(.top, 66)
                    .padding(.trailing, 92)
                    .blur(radius: 10)
            }
            .frame(width: 571, height: 274)
            .position(x: 171.5, y: 78)
            .ignoresSafeArea()
            .clipped()
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
