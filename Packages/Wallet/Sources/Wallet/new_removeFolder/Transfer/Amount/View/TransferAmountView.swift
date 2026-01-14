//
//  TransferAmountView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import Environment
import Foundation
import DesignSystem

struct TransferAmountView<Value: Hashable>: View {
    @Binding var focusState: Value?
    let focusEquals: Value?

    let balance: Decimal
    let tokenomics: ConstantsConfig.Tokenomics
    let onSubmit: ((Decimal) -> Void)?

    @State private var text: String = ""
    @State private var isUpdatingText = false

    @State private var committedAmount: Decimal? = nil

    private let minAmount: Decimal = Decimal(string: "0.000001", locale: Locale(identifier: "en_US_POSIX"))!
    private let maxFractionDigits = 6
    private let maxFractionDigitsForFees = 8

    @State private var expandDistribution: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            Text("Enter amount")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            DataInputTextField(
                backgroundColor: Colors.blackDark,
                trailingIcon: Icons.logoCircleWhite,
                text: $text,
                placeholder: "min: 0.000001",
                maxLength: 100,
                focusState: $focusState,
                focusEquals: focusEquals,
                keyboardType: .decimalPad,
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusState = nil
                    commit(animated: true)
                }
            )

            if let amount = committedAmount {
                let model = TransferFeesModel(
                    amount: amount,
                    tokenomics: tokenomics,
                    hasInviter: AccountManager.shared.inviter != nil,
                    maxFractionDigits: maxFractionDigitsForFees
                )

                TransferFeesView(model: model)
                    .padding(.bottom, 10)

                HStack(spacing: 0) {
                    Text("Total")
                        .appFont(.bodyRegular)

                    Spacer(minLength: 10)

                    HStack(spacing: 5) {
                        Text(formatDecimal10(model.totalWithFees))
                            .appFont(.largeTitleBold)
                            .numericTextIfAvailable()

                        Icons.logoCircleWhite
                            .iconSize(height: 15)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .lineLimit(1)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
        // While typing: only sanitize, no clamping.
        .onChange(of: text) { newValue in
            guard !isUpdatingText else { return }
            let sanitized = sanitizeInput(newValue)
            if sanitized != newValue {
                setTextPreservingEditFeel(sanitized)
            }
        }
        // When focus is lost (keyboard dismissed by any means): commit.
        .onChange(of: focusState) { newFocus in
            if newFocus != focusEquals {
                commit(animated: true)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: committedAmount != nil)
    }

    // MARK: - Commit behavior (best UX)
    private func commit(animated: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            withAnimation(animated ? .easeInOut(duration: 0.18) : nil) {
                committedAmount = nil
                expandDistribution = false
            }
            return
        }

        // If "0" (or "0.0...") was entered -> clear
        if let dec = parseDecimal(trimmed), dec == 0 {
            setTextPreservingEditFeel("")
            withAnimation(animated ? .easeInOut(duration: 0.18) : nil) {
                committedAmount = nil
                expandDistribution = false
            }
            return
        }

        guard let dec = parseDecimal(trimmed) else { return }

        let clamped = clamp(dec)
        let formatted = formatDecimal(clamped)

        if formatted != text {
            setTextPreservingEditFeel(formatted)
        }

        withAnimation(animated ? .easeInOut(duration: 0.18) : nil) {
            committedAmount = clamped
        }

        onSubmit?(clamped)
    }

    private func clamp(_ value: Decimal) -> Decimal {
        var v = value
        if v < 0 { v = 0 } // optional
        if v > 0 && v < minAmount { v = minAmount }
        if v > balance { v = balance }
        return v
    }

    // MARK: - Input shaping (typing-time)
    private func sanitizeInput(_ input: String) -> String {
        let localeSep = Locale.current.decimalSeparator ?? "."
        let acceptableSeps: Set<Character> = [".", ",", Character(localeSep)]

        var result = ""
        var hasSeparator = false
        var fractionCount = 0

        for ch in input {
            if ch.isWholeNumber {
                if hasSeparator {
                    if fractionCount >= maxFractionDigits { continue }
                    fractionCount += 1
                }
                result.append(ch)
            } else if acceptableSeps.contains(ch) {
                if hasSeparator { continue }
                hasSeparator = true
                result.append(Character(localeSep))
            }
        }

        // Allow user to start with separator: "." -> "0."
        if result == String(localeSep) {
            result = "0" + localeSep
        }

        return result
    }

    private func parseDecimal(_ text: String) -> Decimal? {
        let localeSep = Locale.current.decimalSeparator ?? "."
        let normalized = text.replacingOccurrences(of: localeSep, with: ".")
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = TransferAmountFormatters.numberFormatter
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func formatDecimal10(_ value: Decimal) -> String {
        let formatter = TransferAmountFormatters.numberFormatter
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = maxFractionDigitsForFees
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func setTextPreservingEditFeel(_ newText: String) {
        isUpdatingText = true
        text = newText
        isUpdatingText = false
    }

    private var peerFee: (percent: Int, amount: Decimal) {
        let rate = Decimal(tokenomics.fees.peer)
        let amount = (committedAmount ?? 0) * rate
        return (percent: percentInt(from: rate),
                amount: rounded(amount, scale: maxFractionDigitsForFees))
    }

    private var inviterFee: (percent: Int, amount: Decimal) {
        let rate = Decimal(tokenomics.fees.invitation)
        let amount = (committedAmount ?? 0) * rate
        return (percent: percentInt(from: rate),
                amount: rounded(amount, scale: maxFractionDigitsForFees))
    }

    private var burnFee: (percent: Int, amount: Decimal) {
        let rate = Decimal(tokenomics.fees.burn)
        let amount = (committedAmount ?? 0) * rate
        return (percent: percentInt(from: rate),
                amount: rounded(amount, scale: maxFractionDigitsForFees))
    }

    private func rounded(_ value: Decimal, scale: Int) -> Decimal {
        var v = value
        var result = Decimal()
        NSDecimalRound(&result, &v, scale, .plain)
        return result
    }

    private func percentInt(from rate: Decimal) -> Int {
        let p = rounded(rate * 100, scale: 0)
        return NSDecimalNumber(decimal: p).intValue
    }

    private var hasInviter: Bool {
        AccountManager.shared.inviter != nil
    }

    private var totalFeeRate: Decimal {
        Decimal(
            tokenomics.fees.peer
            + tokenomics.fees.burn
            + (hasInviter ? tokenomics.fees.invitation : 0)
        )
    }

    private var totalFee: (percent: Int, amount: Decimal) {
        let base = committedAmount ?? 0
        let amount = rounded(base * totalFeeRate, scale: maxFractionDigitsForFees)
        return (percent: percentInt(from: totalFeeRate), amount: amount)
    }

    private var totalWithFees: Decimal {
        let base = committedAmount ?? 0
        return rounded(base + totalFee.amount, scale: maxFractionDigitsForFees)
    }
}
