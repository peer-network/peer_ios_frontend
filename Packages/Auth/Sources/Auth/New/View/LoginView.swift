//
//  LoginView.swift
//  Auth
//
//  Created by Artem Vasin on 19.06.25.
//

import SwiftUI
import Environment
import DesignSystem

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authVM: AuthorizationViewModel
    
    @AppStorage("username", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var username = ""
    @AppStorage("rememberMe", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var rememberMe = true

    private enum FocusField: Hashable {
        case email
        case password
    }
    
    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        pageContent
    }
    
    @ViewBuilder
    private var pageContent: some View {
        Images.logoText
            .frame(height: 56.8)
            .padding(.bottom, 15)

        welcomeText(username: username)
            .padding(.bottom, 34)
        
        emailTextField
            .padding(.bottom, 10)
        
        passwordTextField
            .padding(.bottom, 10)

        if !authVM.loginError.isEmpty {
            errorView(authVM.loginError)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 16)
        }

        rememberMeSection
            .padding(.bottom, 24)
        
        loginButton
            .padding(.bottom, 24)
        
        orSeparator
            .padding(.bottom, 15)
        
        registerButton
    }
    
    @ViewBuilder
    private func welcomeText(username: String) -> some View {
        let isUsernameEmpty = username.isEmpty

        let titleText = isUsernameEmpty ? "Hey there!" : "Hey, \(username)!"
        let subtitleText = isUsernameEmpty ? "Glad you're here" : "Welcome back"
        let desctiptionText = isUsernameEmpty ? "Don’t have an account? Register now to get started!" : "It’s good to see you again! Log in to continue your journey with us!"

        VStack(alignment: .leading, spacing: 0) {
            Text(titleText)
                .appFont(.extraLargeTitleRegular)
                .foregroundStyle(Colors.whitePrimary)

            Text(subtitleText)
                .appFont(.extraLargeTitleRegular)
                .foregroundStyle(Colors.whitePrimary)

            Text(desctiptionText)
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whiteSecondary)
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var emailTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.envelope,
            text: $authVM.loginEmail,
            placeholder: "E-mail",
            maxLength: 999, // MARK: Take it from Constants
            focusState: $focusedField,
            focusEquals: .email,
            keyboardType: .emailAddress,
            textContentType: .username,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .next) {
                focusedField = .password
            }
    }
    
    private var passwordTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.lock,
            text: $authVM.loginPassword,
            placeholder: "Password",
            maxLength: appState.getConstants()?.data.user.password.maxLength ?? 999,
            isSecure: true,
            focusState: $focusedField,
            focusEquals: .password,
            keyboardType: .asciiCapable,
            textContentType: .password,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .done
        )
    }
    
    private var rememberMeSection: some View {
        HStack(spacing: 4) {
            CheckmarkButton(text: Text("Remember me"), isChecked: $rememberMe)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    authVM.moveToForgotPasswordScreen()
                }
            } label: {
                Text("Forgot password?")
                    .underline(true, pattern: .solid)
            }
        }
        .appFont(.smallLabelRegular)
        .foregroundStyle(Colors.whiteSecondary)
    }
    
    private var orSeparator: some View {
        HStack(spacing: 13) {
            Rectangle()
                .frame(height: 1)
            
            Text("Or")
                .textCase(.uppercase)
                .appFont(.smallLabelRegular)
            
            Rectangle()
                .frame(height: 1)
        }
        .foregroundStyle(Colors.whiteSecondary)
    }
    
    @ViewBuilder
    private var loginButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Login")

        AsyncStateButton(config: config) {
            focusedField = nil

            await authVM.loginButtonTapped()
        }
        .disabled(authVM.isLoginButtonDisabled)
    }
    
    @ViewBuilder
    private var registerButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .secondary, title: "Register now")

        StateButton(config: config) {
            focusedField = nil

            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.moveToReferralCodeScreen()
            }
        }
    }

    private func errorView(_ text: String) -> some View {
        Text(text)
            .appFont(.smallLabelRegular)
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.redAccent)
    }
}
