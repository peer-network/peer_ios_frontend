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

        resetButton
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
        DataInputTextField(text: $authVM.forgotPasswordEmail, placeholder: "E-mail", maxLength: 999, focusState: $focusedField, focusEquals: .email)
            .submitLabel(.done)
    }

    @ViewBuilder
    private var resetButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Reset password")

        AsyncStateButton(config: config) {
            try? await Task.sleep(for: .seconds(3))
        }
    }
}
