//
//  LoginView.swift
//  Auth
//
//  Created by Artem Vasin on 19.06.25.
//

import SwiftUI
import DesignSystem

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel
    
    @AppStorage("username", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var username = "artem" // TODO: change to empty
    
    private enum FocusField: Hashable {
        case email
        case password
    }
    
    @FocusState private var focusedField: FocusField?
    
    @State private var rememberMeChecked = true
    
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
            .padding(.bottom, 16)
        
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
        let subtitleText = isUsernameEmpty ? "Glad You're Here" : "Welcome back"
        let desctiptionText = isUsernameEmpty ? "Don’t have an account? Register now to get started!" : "It’s good to see you again! Log in to continue your journey with us!"
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Text(titleText)
                    .appFont(.extraLargeTitleRegular)
                    .foregroundStyle(Colors.whitePrimary)
                
                LottieView(animation: .handWave)
                    .frame(width: 31, height: 31)
            }
            
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
        DataInputTextField(text: $authVM.loginEmail, placeholder: "E-mail", maxLength: 100, focusState: $focusedField, focusEquals: .email)
            .submitLabel(.continue)
    }
    
    private var passwordTextField: some View {
        DataInputTextField(text: $authVM.loginPassword, placeholder: "Password", maxLength: 999, focusState: $focusedField, focusEquals: .password)
            .submitLabel(.done)
    }
    
    private var rememberMeSection: some View {
        HStack(spacing: 4) {
            CheckmarkButton(text: "Remember me", isChecked: $rememberMeChecked)
            
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
            try? await Task.sleep(for: .seconds(3))
        }
    }
    
    @ViewBuilder
    private var registerButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .secondary, title: "Register now", icon: IconsNew.arrowRight, iconPlacement: .trailing)

        StateButton(config: config) {
            focusedField = nil

            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.moveToReferralCodeScreen()
            }
        }
    }
}
