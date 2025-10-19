//
//  RegisterView.swift
//  Auth
//
//  Created by Artem Vasin on 24.06.25.
//

import SwiftUI
import Environment
import DesignSystem

struct RegisterView: View {
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case email
        case username
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
            .padding(.bottom, 4)

        descriptionText
            .padding(.bottom, 24)

        emailTextField
            .padding(.bottom, 10)

        usernameTextField
            .padding(.bottom, 10)

        passwordTextField

        if authVM.regPasswordStrength != nil {
            PasswordStrengthBarsView(password: authVM.regPassword)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.top, 3)
        }

        Spacer()
            .frame(height: 10)

        confirmPasswordTextField
            .padding(.bottom, 10)

        agreementsCheckmarks
            .padding(.horizontal, 16)
            .padding(.bottom, 15)

        if !authVM.regError.isEmpty {
            errorView(authVM.regError)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 15)
        }

        if passwordsDoNotMatch {
            errorView("Passwords do not match.")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 15)
        }

        registerButton
            .padding(.bottom, 10)

        goToLoginScreenButton
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var titleText: some View {
        Text("Register")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("Create your account in few seconds and start earning on your favorite content.")
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var emailTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.envelope,
            text: $authVM.regEmail,
            placeholder: "E-mail",
            maxLength: 999,
            focusState: $focusedField,
            focusEquals: .email,
            keyboardType: .emailAddress,
            textContentType: .username,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .next) {
                focusedField = .username
            }
    }

    private var usernameTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.person,
            text: $authVM.regUsername,
            placeholder: "User name",
            maxLength: appState.getConstants()?.data.user.username.maxLength ?? 999,
            focusState: $focusedField,
            focusEquals: .username,
            keyboardType: .asciiCapable,
            textContentType: nil,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .next) {
                focusedField = .password
            }
    }

    private var passwordTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.lock,
            text: $authVM.regPassword,
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
        .onChange(of: authVM.regPassword) {
            withAnimation(.easeInOut(duration: 0.2)) {
                passwordsDoNotMatch = false
                authVM.evaluateRegisterPasswordStrength()
            }
        }
    }

    private var confirmPasswordTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.lock,
            text: $authVM.regPasswordRepeat,
            placeholder: "Confirm password",
            maxLength: appState.getConstants()?.data.user.password.maxLength ?? 999,
            isSecure: true,
            focusState: $focusedField,
            focusEquals: .confirmPassword,
            keyboardType: .asciiCapable,
            textContentType: .newPassword,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .done
        )
        .onChange(of: authVM.regPasswordRepeat) {
            withAnimation(.easeInOut(duration: 0.2)) {
                passwordsDoNotMatch = false
            }
        }
    }

    private var agreementsCheckmarks: some View {
        VStack(alignment: .leading, spacing: 10) {
            let privacyText = Text("I agree to the ") + Text("[Privacy Policy](https://peerapp.de/privacy.html)").underline(true, pattern: .solid) + Text(".")
            CheckmarkButton(text: privacyText, isChecked: $authVM.agreedToPrivacyPolicy)

            let eulaText = Text("I agree to the ") + Text("[End User License Agreement](https://peerapp.de/EULA.html)").underline(true, pattern: .solid) + Text(".")
            CheckmarkButton(text: eulaText, isChecked: $authVM.agreedToEULA)
        }
        .tint(Colors.whitePrimary) // For making links white
    }

    @ViewBuilder
    private var registerButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Register")

        AsyncStateButton(config: config) {
            focusedField = nil

            if authVM.regPassword != authVM.regPasswordRepeat {
                withAnimation(.easeInOut(duration: 0.2)) {
                    passwordsDoNotMatch = true
                }
                return
            }

            await authVM.registerButtonTapped()
        }
        .disabled(authVM.isRegisterButtonDisabled || passwordsDoNotMatch)
    }

    private var goToLoginScreenButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.alreadyRegisteredButtonTapped()
            }
        } label: {
            HStack(spacing: 4.22) {
                Text("Already registered?")
                    .foregroundStyle(Colors.whiteSecondary)

                Text("Login now")
                    .underline(true, pattern: .solid)
                    .foregroundStyle(Colors.whitePrimary)
            }
            .appFont(.smallLabelRegular)
            .contentShape(.rect)
        }
    }

    private func errorView(_ text: String) -> some View {
        Text(text)
            .appFont(.smallLabelRegular)
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.redAccent)
    }
}
