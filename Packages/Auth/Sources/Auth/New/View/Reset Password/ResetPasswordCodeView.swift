//
//  ResetPasswordCodeView.swift
//  Auth
//
//  Created by Artem Vasin on 25.06.25.
//

import SwiftUI
import DesignSystem

struct ResetPasswordCodeView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case code
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

        emailTextField
            .padding(.bottom, 15)

        continueButton
    }

    private var titleText: some View {
        Text("Forgot password")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("We sent a code to your email address. Please, enter the code to change your password.")
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var emailTextField: some View {
        DataInputTextField(text: $authVM.forgotPasswordCode, placeholder: "Enter code", maxLength: 999, focusState: $focusedField, focusEquals: .code)
            .submitLabel(.done)
    }

    @ViewBuilder
    private var continueButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Continue")

        StateButton(config: config) {
            focusedField = nil
            
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.moveToForgotPasswordNewPassScreen()
            }
        }
    }
}
