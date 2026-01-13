//
//  ResetPasswordView.swift
//  Auth
//
//  Created by Artem Vasin on 24.06.25.
//

import SwiftUI
import DesignSystem

struct ResetPasswordView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case email
    }

    @State private var focusedField: FocusField?
    
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

        if !authVM.forgotPasswordErrorEmail.isEmpty {
            errorView(authVM.forgotPasswordErrorEmail)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 5)
        }

        resetButton
            .padding(.top, 5)
    }

    private var titleText: some View {
        Text("Forgot password")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("Please enter your email and we’ll send you a reset link.")
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var emailTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.envelope,
            text: $authVM.forgotPasswordEmail,
            placeholder: "E-mail",
            maxLength: 999, // MARK: Take it from Constants
            focusState: $focusedField,
            focusEquals: .email,
            keyboardType: .emailAddress,
            textContentType: .username,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .done
        )
    }

    @ViewBuilder
    private var resetButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Send")

        AsyncStateButton(config: config) {
            focusedField = nil
            
            await authVM.sendResetPasswordEmailButtonTapped()
        }
        .disabled(authVM.isSendResetCodeButtonDisabled)
    }

    private func errorView(_ text: String) -> some View {
        Text(text)
            .appFont(.smallLabelRegular)
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.redAccent)
    }
}
