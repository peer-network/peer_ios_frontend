//
//  RegisterView.swift
//  Auth
//
//  Created by Artem Vasin on 24.06.25.
//

import SwiftUI
import DesignSystem

struct RegisterView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case email
        case username
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

        descriptionText
            .padding(.bottom, 24)

        emailTextField
            .padding(.bottom, 10)

        usernameTextField
            .padding(.bottom, 10)

        passwordTextField

        if authVM.regPasswordStrength != .empty {
            PasswordStrengthBarsView(strength: authVM.regPasswordStrength)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
        } else {
            Spacer()
                .frame(height: 10)
        }

        confirmPasswordTextField
            .padding(.bottom, 15)

        registerButton
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
        DataInputTextField(text: $authVM.regEmail, placeholder: "E-mail", maxLength: 999, focusState: $focusedField, focusEquals: .email)
            .submitLabel(.continue)
    }

    private var usernameTextField: some View {
        DataInputTextField(text: $authVM.regUsername, placeholder: "User name", maxLength: 999, focusState: $focusedField, focusEquals: .username)
            .submitLabel(.continue)
    }

    private var passwordTextField: some View {
        DataInputTextField(text: $authVM.regPassword, placeholder: "Password", maxLength: 999, focusState: $focusedField, focusEquals: .password)
            .submitLabel(.continue)
            .onChange(of: authVM.regPassword) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    authVM.evaluateRegisterPasswordStrength()
                }
            }
    }

    private var confirmPasswordTextField: some View {
        DataInputTextField(text: $authVM.regPasswordRepeat, placeholder: "Confirm password", maxLength: 999, focusState: $focusedField, focusEquals: .confirmPassword)
            .submitLabel(.done)
    }

    @ViewBuilder
    private var registerButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Register")

        StateButton(config: config) {
            focusedField = nil
            
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.registerButtonTapped()
            }
        }
    }
}
