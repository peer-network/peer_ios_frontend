//
//  CheckoutTotalAmountView.swift
//  PeerApp
//
//  Created by Artem Vasin on 12.01.26.
//

import SwiftUI
import DesignSystem

struct CheckoutTotalAmountView: View {
    let model: CheckoutAmount
    let basePurposeText: String
    let feesText: String

    @State private var expandFees: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            totalAmountView

            baseAmountView

            feesAmountView
        }
        .lineLimit(1)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var totalAmountView: some View {
        HStack(spacing: 0) {
            Text("Total amount")
                .appFont(.smallLabelBold)

            Spacer(minLength: 5)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Text(formatDecimal(model.finalTotalAmount))
                    .appFont(.largeTitleBold)

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
    }

    private var baseAmountView: some View {
        HStack(spacing: 0) {
            Text(basePurposeText)
                .appFont(.smallLabelRegular)

            Spacer(minLength: 5)

            HStack(spacing: 5) {
                Text(formatDecimal(model.baseAmount))
                    .appFont(.bodyBold)

                Icons.logoCircleWhite
                    .iconSize(height: 15)

                Icons.arrowDown
                    .iconSize(height: 8)
                    .opacity(0)
            }
        }
        .foregroundStyle(Colors.whiteSecondary)
    }

    private var feesAmountView: some View {
        VStack(spacing: 5) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.92)) {
                    expandFees.toggle()
                }
            } label: {
                HStack(spacing: 0) {
                    Text(feesText)
                        .appFont(.smallLabelRegular)

                    Spacer(minLength: 5)

                    HStack(spacing: 5) {
                        Text(formatDecimal(model.totalFee.amount))
                            .appFont(.bodyBold)

                        Icons.logoCircleWhite
                            .iconSize(height: 15)

                        Icons.arrowDown
                            .iconSize(height: 8)
                            .rotationEffect(expandFees ? .degrees(180) : .degrees(0))
                            .animation(.spring(response: 0.32, dampingFraction: 0.92), value: expandFees)
                    }
                }
                .foregroundStyle(Colors.whiteSecondary)
                .contentShape(.rect)
            }

            if expandFees {
                Group {
                    HStack(spacing: 0) {
                        Text("\(model.peerFee.percent)% to Peer Bank (platform fee)")
                            .appFont(.smallLabelRegular)

                        Spacer(minLength: 5)

                        HStack(spacing: 5) {
                            Text(formatDecimal(model.peerFee.amount))
                                .appFont(.smallLabelRegular)

                            Icons.logoCircleWhite
                                .iconSize(height: 7.89)
                        }
                    }

                    HStack(spacing: 0) {
                        Text("\(model.burnFee.percent)% Burned (removed from supply)")
                            .appFont(.smallLabelRegular)

                        Spacer(minLength: 5)

                        HStack(spacing: 5) {
                            Text(formatDecimal(model.burnFee.amount))
                                .appFont(.smallLabelRegular)

                            Icons.logoCircleWhite
                                .iconSize(height: 7.89)
                        }
                    }

                    if model.hasInviter {
                        HStack(spacing: 0) {
                            Text("\(model.inviterFee.percent)% to your inviter")
                                .appFont(.smallLabelRegular)

                            Spacer(minLength: 5)

                            HStack(spacing: 5) {
                                Text(formatDecimal(model.inviterFee.amount))
                                    .appFont(.smallLabelRegular)

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
        let formatter = numberFormatter
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = model.maxFractionDigits
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = false
        return f
    }()
}
