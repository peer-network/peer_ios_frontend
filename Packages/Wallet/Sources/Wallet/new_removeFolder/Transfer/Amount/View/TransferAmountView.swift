//
//  TransferAmountView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import Foundation
import DesignSystem

struct TransferAmountView<Value: Hashable>: View {
    @Binding var focusState: Value?
    let focusEquals: Value?

    let balance: Decimal
    let onSubmit: ((Decimal) -> Void)?

    @State private var text: String = ""
    @State private var isUpdatingText = false

    private let minAmount: Decimal = Decimal(string: "0.00000001", locale: Locale(identifier: "en_US_POSIX"))!
    private let maxFractionDigits = 8

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
                placeholder: "min: 0.00000001",
                maxLength: 100,
                focusState: $focusState,
                focusEquals: focusEquals,
                keyboardType: .decimalPad,
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusState = nil            // dismiss keyboard
                    commit()                    // clamp + submit
                }
            )
        }
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
            // If we *were* focused and now we're not, commit.
            if newFocus != focusEquals {
                commit()
            }
        }
    }

    // MARK: - Commit behavior (best UX)
    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // If "0" (or "0.0...") was entered -> clear
        if let dec = parseDecimal(trimmed), dec == 0 {
            setTextPreservingEditFeel("")
            return
        }

        guard let dec = parseDecimal(trimmed) else { return }

        let clamped = clamp(dec)

        // Write back a nicely formatted value
        let formatted = formatDecimal(clamped)

        if formatted != text {
            setTextPreservingEditFeel(formatted)
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func setTextPreservingEditFeel(_ newText: String) {
        // For most custom textfields this is fine; cursor preservation depends on the implementation.
        isUpdatingText = true
        text = newText
        isUpdatingText = false
    }
}
