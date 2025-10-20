//
//  ResetPasswordNewPassView.swift
//  Auth
//
//  Created by Artem Vasin on 25.06.25.
//

import SwiftUI
import DesignSystem
import Environment

struct ResetPasswordNewPassView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case password
        case confirmPassword
    }

    @FocusState private var focusedField: FocusField?

    @State private var passwordsDoNotMatch: Bool = false

    var body: some View {
        pageContent
    }

    @ViewBuilder
    private var pageContent: some View {
        titleText
            .padding(.bottom, 15)

        passwordTextField

        if authVM.forgotPasswordStrength != nil {
            PasswordStrengthBarsView(password: authVM.forgotPasswordNewPass)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.top, 3)
        }

        Spacer()
            .frame(height: 10)

        confirmPasswordTextField

        if passwordsDoNotMatch {
            errorView("Passwords do not match.")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }

        if !authVM.forgotPasswordErrorUpdatePassword.isEmpty {
            errorView(authVM.forgotPasswordErrorUpdatePassword)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }

        updatePasswordButton
            .padding(.top, 15)
    }

    private var titleText: some View {
        Text("Set a new password")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var passwordTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.lock,
            text: $authVM.forgotPasswordNewPass,
            placeholder: "Password",
            maxLength: appState.getConstants()?.data.user.password.maxLength ?? 999,
            isSecure: true,
            focusState: $focusedField,
            focusEquals: .password,
            keyboardType: .asciiCapable,
            textContentType: .newPassword,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .next,
            onSubmit: {
                focusedField = .confirmPassword
            }
        )
        .onChange(of: authVM.forgotPasswordNewPass) {
            withAnimation(.easeInOut(duration: 0.2)) {
                passwordsDoNotMatch = false
                authVM.evaluateForgotPasswordStrength()
            }
        }
    }

    private var confirmPasswordTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.lock,
            text: $authVM.forgotPasswordRepeatPass,
            placeholder: "Confirm password",
            maxLength:  appState.getConstants()?.data.user.password.maxLength ?? 999,
            isSecure: true,
            focusState: $focusedField,
            focusEquals: .confirmPassword,
            keyboardType: .asciiCapable,
            textContentType: .newPassword,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .done
        )
        .onChange(of: authVM.forgotPasswordRepeatPass) {
            withAnimation(.easeInOut(duration: 0.2)) {
                passwordsDoNotMatch = false
            }
        }
    }

    @ViewBuilder
    private var updatePasswordButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Update password")

        AsyncStateButton(config: config) {
            focusedField = nil

            if authVM.forgotPasswordNewPass != authVM.forgotPasswordRepeatPass {
                withAnimation(.easeInOut(duration: 0.2)) {
                    passwordsDoNotMatch = true
                }
                return
            }

            await authVM.updatePasswordButtonTapped()
        }
        .disabled(authVM.isUpdatePasswordButtonDisabled || passwordsDoNotMatch)
    }

    private func errorView(_ text: String) -> some View {
        Text(text)
            .appFont(.smallLabelRegular)
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.redAccent)
    }
}
