//
//  PasswordStrengthBarsView.swift
//  Auth
//
//  Created by Артем Васин on 27.01.25.
//

import SwiftUI
import DesignSystem

struct PasswordStrengthBarsView: View {
    let password: String

    private var evaluation: PasswordEvaluation {
        PasswordPolicy.evaluate(password)
    }

    private var strength: PasswordStrength {
        evaluation.strength
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(strength.rawValue)
                .appFont(.smallLabelBold)
                .foregroundStyle(barsColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 1)

            HStack(alignment: .center, spacing: 5.5) {
                ForEach(0..<5, id: \.self) { bar in
                    RoundedRectangle(cornerRadius: 29)
                        .frame(height: 2)
                        .foregroundStyle(bar < barsAmount ? barsColor : Colors.passwordBarsEmpty)
                }
            }
            .padding(.bottom, 4.74)

            Text(hintText)
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Hint builder

    private var hintText: String {
        if !evaluation.unmetRequirements.isEmpty {
            // Always prefix with "Minimum "
            let list = evaluation.unmetRequirements.map { $0.phrase }.joined(separator: ", ")
            return "Minimum \(list)"
        }

        // All minimums satisfied
        if strength == .strong {
            return "All set! Your password is rock solid"
        } else {
            return "Optionally: 12+ characters or a special character"
        }
    }

    // MARK: - Bars & colors

    private var barsAmount: Int {
        switch strength {
            case .empty:            0
            case .veryWeak:         1
            case .weak:             2
            case .notStrongEnough:   3
            case .good:             4
            case .strong:           5
        }
    }

    private var barsColor: Color {
        switch strength {
            case .empty:
                Colors.passwordBarsEmpty
            case .veryWeak, .weak:
                Colors.passwordBarsRed
            case .notStrongEnough:
                Colors.passwordBarsYellow
            case .good, .strong:
                Colors.passwordBarsGreen
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PasswordStrengthBarsView(password: "")                 // shows all requirements
        PasswordStrengthBarsView(password: "abc")              // shows min length, 1 uppercase, 1 number
        PasswordStrengthBarsView(password: "Abcdefgh")         // shows 1 number
        PasswordStrengthBarsView(password: "Abcdefg1")         // "Optionally: 12+ characters or a special character"
        PasswordStrengthBarsView(password: "Abcdefg1!!!!")     // "All set! Your password is rock solid"
    }
    .padding()
    .background(Color.black)
}
