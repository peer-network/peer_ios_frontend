//
//  EditPasswordView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 13.05.25.
//

import SwiftUI
import DesignSystem
import Analytics
import Environment
import Models

public struct EditPasswordView: View {
    private let onSubmit: (String, String) async -> Result<Void, APIError>

    @State private var newPassword: String = ""
    @State private var showNewPassword = false

    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isCurrentPasswordFocused: Bool

    @State private var passwordStrength: PasswordStrength = .empty

    public init(onSubmit: @escaping (String, String) async -> Result<Void, APIError>) {
        self.onSubmit = onSubmit
    }

    public var body: some View {
        DataEditView(
            title: "Change password",
            submitLabel: "Save",
            submitAction: { currentPassword in
                await onSubmit(newPassword, currentPassword)
            },
            content: {
                newPasswordTextField

                if passwordStrength != .empty {
                    PasswordStrengthBarsView(strength: passwordStrength)
                        .padding(.horizontal, 15)
                }
            },
            isPasswordFocused: $isCurrentPasswordFocused
        )
        .onAppear {
            isNewPasswordFocused = true
        }
        .onChange(of: newPassword) {
            if newPassword.isEmpty {
                withAnimation {
                    passwordStrength = .empty
                }
            } else {
                withAnimation {
                    passwordStrength = evaluatePasswordStrength(newPassword)
                }
            }
        }
    }

    private var newPasswordTextField: some View {
        FormTextField(
            placeholder: "New password",
            text: $newPassword,
            type: showNewPassword ? .default : .secured,
            icon: newPassword.isEmpty ? nil : (showNewPassword ? Icons.eyeSlash : Icons.eye)
        ) {
            showNewPassword.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isNewPasswordFocused = true
            }
        }
        .focused($isNewPasswordFocused)
        .submitLabel(.next)
        .onSubmit {
            isCurrentPasswordFocused = true
        }
        .textContentType(.password)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isNewPasswordFocused = true
        }
    }

    // MARK: - Password Strength

    enum PasswordStrength: String {
        case empty = ""
        case tooWeak = "Too weak!"
        case notStrongEnough = "Not strong enough!"
        case good = "Good!"
        case excellent = "Excellent!"
    }

    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        // At minimum, a password must be:
        // 1) >= 8 characters
        // 2) contain at least one uppercase letter
        // 3) contain at least one lowercase letter
        // 4) contain at least one digit

        // Check each requirement
        let lengthRequirement = password.count >= 8
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil

        // Count how many are satisfied
        var score = 0
        score += lengthRequirement ? 1 : 0
        score += hasUppercase      ? 1 : 0
        score += hasLowercase      ? 1 : 0
        score += hasDigit          ? 1 : 0

        // Additional requirement to qualify as "excellent"
        // e.g., length ≥ 12 or has a special character, etc.
        let hasSpecialCharacter = password.rangeOfCharacter(
            from: CharacterSet.punctuationCharacters.union(.symbols)
        ) != nil
        let lengthBonus = password.count >= 12

        let meetsExcellentBonus = hasSpecialCharacter || lengthBonus

        // Decide on final rating:
        switch score {
            case 0, 1:
                return .tooWeak
            case 2:
                return .notStrongEnough
            case 3:
                // 3 means one of the four core checks is missing
                // so still "notStrongEnough" if it doesn't meet all 4
                return .notStrongEnough
            case 4:
                // All minimum requirements are met
                return meetsExcellentBonus ? .excellent : .good
            default:
                // Should never hit here, but as a fallback:
                return .tooWeak
        }
    }
}

fileprivate struct PasswordStrengthBarsView: View {
    let strength: EditPasswordView.PasswordStrength

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<4, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 29)
                    .frame(width: 36, height: 2)
                    .foregroundStyle(bar < barsAmount ? barsColor : Colors.passwordBarsEmpty)
                    .padding(.trailing, 3)
            }
            .layoutPriority(1)

            Spacer()
                .frame(minWidth: 7)

            Text(strength.rawValue)
                .font(.customFont(weight: .regular, size: .footnote))
                .multilineTextAlignment(.center)
                .foregroundStyle(Colors.whitePrimary.opacity(0.6))
                .layoutPriority(1)
        }
    }

    private var barsAmount: Int {
        switch strength {
            case .empty:
                0
            case .tooWeak:
                1
            case .notStrongEnough:
                2
            case .good:
                3
            case .excellent:
                4
        }
    }

    private var barsColor: Color {
        switch strength {
            case .empty:
                Colors.passwordBarsEmpty
            case .tooWeak:
                Colors.passwordBarsRed
            case .notStrongEnough:
                Colors.passwordBarsRed
            case .good:
                Colors.passwordBarsYellow
            case .excellent:
                Colors.passwordBarsGreen
        }
    }
}

#Preview {
    EditPasswordView(onSubmit: {_, _ in return .success(()) })
        .analyticsService(MockAnalyticsService())
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
