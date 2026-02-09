//
//  TransferFeesView.swift
//  Wallet
//
//  Created by Artem Vasin on 22.12.25.
//

import SwiftUI
import Foundation
import DesignSystem
import Environment

// Cache outside generic types
enum TransferAmountFormatters {
    static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = false
        return f
    }()
}

extension View {
    @ViewBuilder
    func numericTextIfAvailable() -> some View {
        if #available(iOS 17.0, *) { self.contentTransition(.numericText()) }
        else { self }
    }
}

// MARK: - Reusable View (keeps your exact layout)

struct TransferFeesView: View {
    let model: TransferFeesModel

    @State private var expandDistribution: Bool = false

    private var hasInviter: Bool { model.hasInviter }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.92)) {
                    expandDistribution.toggle()
                }
            } label: {
                HStack(spacing: 0) {
                    Text("Transfer fee")
                        .appFont(.smallLabelRegular)

                    Spacer(minLength: 5)

                    HStack(spacing: 5) {
                        Text(formatDecimal(model.totalFee.amount))
                            .appFont(.bodyBold)
                            .numericTextIfAvailable()

                        Icons.logoCircleWhite
                            .iconSize(height: 15)

                        Icons.arrowDown
                            .iconSize(height: 8)
                            .rotationEffect(expandDistribution ? .degrees(180) : .degrees(0))
                            .animation(.spring(response: 0.32, dampingFraction: 0.92), value: expandDistribution)
                    }
                }
                .foregroundStyle(Colors.whiteSecondary)
                .contentShape(.rect)
            }

            if expandDistribution {
                VStack(spacing: 5.26) {
                    HStack(spacing: 0) {
                        Text("\(model.peerFee.percent)% to Peer Bank (platform fee)")
                            .appFont(.smallLabelRegular)
                            .foregroundStyle(Colors.whiteSecondary)

                        Spacer(minLength: 5.26)

                        HStack(spacing: 5.26) {
                            Text(formatDecimal(model.peerFee.amount))
                                .appFont(.smallLabelRegular)
                                .numericTextIfAvailable()

                            Icons.logoCircleWhite
                                .iconSize(height: 7.89)
                        }
                    }
                    .padding(.top, 5.26)
                    .padding(.top, -20)

                    HStack(spacing: 0) {
                        Text("\(model.burnFee.percent)% Burned (removed from supply)")
                            .appFont(.smallLabelRegular)
                            .foregroundStyle(Colors.whiteSecondary)

                        Spacer(minLength: 5.26)

                        HStack(spacing: 5.26) {
                            Text(formatDecimal(model.burnFee.amount))
                                .appFont(.smallLabelRegular)
                                .numericTextIfAvailable()

                            Icons.logoCircleWhite
                                .iconSize(height: 7.89)
                        }
                    }

                    if hasInviter {
                        HStack(spacing: 0) {
                            Text("\(model.inviterFee.percent)% to your inviter")
                                .appFont(.smallLabelRegular)
                                .foregroundStyle(Colors.whiteSecondary)

                            Spacer(minLength: 5.26)

                            HStack(spacing: 5.26) {
                                Text(formatDecimal(model.inviterFee.amount))
                                    .appFont(.smallLabelRegular)
                                    .numericTextIfAvailable()

                                Icons.logoCircleWhite
                                    .iconSize(height: 7.89)
                            }
                        }
                    }
                }
                .foregroundStyle(Colors.whiteSecondary)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = TransferAmountFormatters.numberFormatter
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = model.maxFractionDigits
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}
