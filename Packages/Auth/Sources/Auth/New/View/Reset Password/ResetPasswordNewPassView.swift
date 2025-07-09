//
//  ResetPasswordNewPassView.swift
//  Auth
//
//  Created by Artem Vasin on 25.06.25.
//

import SwiftUI
import DesignSystem

struct ResetPasswordNewPassView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case password
        case confirmPassword
    }

    @FocusState private var focusedField: FocusField?

    var body: some View {
        pageContent
    }

    @ViewBuilder
    private var pageContent: some View {
        titleText
            .padding(.bottom, 4)

        descriptionText
            .padding(.bottom, 24)

        passwordTextField

        if authVM.forgotPasswordStrength != .empty {
            PasswordStrengthBarsView(strength: authVM.forgotPasswordStrength)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
        } else {
            Spacer()
                .frame(height: 10)
        }

        confirmPasswordTextField
            .padding(.bottom, 15)

        updatePasswordButton
    }

    private var titleText: some View {
        Text("Set a new password")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("Create a new password. Ensure it differs from previous ones for security.")
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var passwordTextField: some View {
        DataInputTextField(text: $authVM.forgotPasswordNewPass, placeholder: "Password", maxLength: 999, focusState: $focusedField, focusEquals: .password)
            .submitLabel(.continue)
            .onChange(of: authVM.forgotPasswordNewPass) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    authVM.evaluateForgotPasswordStrength()
                }
            }
    }

    private var confirmPasswordTextField: some View {
        DataInputTextField(text: $authVM.forgotPasswordRepeatPass, placeholder: "Confirm password", maxLength: 999, focusState: $focusedField, focusEquals: .confirmPassword)
            .submitLabel(.done)
    }

    @ViewBuilder
    private var updatePasswordButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Update password")

        AsyncStateButton(config: config) {
            try? await Task.sleep(for: .seconds(3))
        }
    }
}
