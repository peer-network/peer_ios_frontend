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

        codeTextField
            .padding(.bottom, 15)

        if !authVM.forgotPasswordErrorBadCode.isEmpty {
            errorView(authVM.forgotPasswordErrorBadCode)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 15)
        }

        verifyButton
            .padding(.bottom, 15)

        if !authVM.forgotPasswordErrorResendEmail.isEmpty {
            errorView(authVM.forgotPasswordErrorResendEmail)
                .frame(maxWidth: .infinity, alignment: .center)
        }

        resendCodeButton
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 9)
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

    private var codeTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.envelopeWithCode,
            text: $authVM.forgotPasswordCode,
            placeholder: "Enter code",
            maxLength: 999, // MARK: Take it from Constants
            focusState: $focusedField,
            focusEquals: .code,
            keyboardType: .asciiCapable,
            textContentType: nil,
            autocorrectionDisabled: true,
            autocapitalization: .none,
            returnKeyType: .done
        )
    }

    @ViewBuilder
    private var verifyButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Verify code")

        AsyncStateButton(config: config) {
            focusedField = nil
            
            await authVM.verifyResetPasswordCodeButtonTapped()
        }
        .disabled(authVM.isVerifyResetCodeButtonDisabled)
    }

    private var resendCodeButton: some View {
        Button {
            Task {
                await authVM.resendPasswordResetEmailButtonTapped()
            }
        } label: {
            HStack(spacing: 4.22) {
                Text("Didn’t get the code?")

                Text("Resend code")
                    .appFont(.smallLabelBold)
                    .underline(true, pattern: .solid)
                    .foregroundStyle(Colors.whitePrimary)
            }
            .appFont(.smallLabelRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func errorView(_ text: String) -> some View {
        Text(text)
            .appFont(.smallLabelRegular)
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.redAccent)
    }
}
