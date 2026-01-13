//
//  ReferralCodeView.swift
//  Auth
//
//  Created by Artem Vasin on 23.06.25.
//

import SwiftUI
import DesignSystem

struct ReferralCodeView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private enum FocusField: Hashable {
        case referralCode
    }

    @State private var focusedField: FocusField?

    var body: some View {
        pageContent
    }

    @ViewBuilder
    private var pageContent: some View {
        welcomeText
            .padding(.bottom, 4)

        descriptionText
            .padding(.bottom, 24)

        codeTextField

        if !authVM.referralError.isEmpty {
            errorView(authVM.referralError)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }

        verifyButton
            .padding(.top, 15)
            .padding(.bottom, 24)

        getReferralCodeButton
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var welcomeText: some View {
        HStack(spacing: 0) {
            Text("Welcome to ").appFont(.extraLargeTitleRegular)
            Text("peer!").appFont(.extraLargeTitleBoldItalic)
        }
        .foregroundStyle(Colors.whitePrimary)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("One quick step left! Enter your referral code to complete registration.")
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var codeTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.referral,
            text: $authVM.referralCode,
            placeholder: "Referral code",
            maxLength: 999,
            focusState: $focusedField,
            focusEquals: .referralCode,
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
            
            await authVM.verifyReferralCodeButtonTapped()
        }
        .disabled(authVM.isVerifyReferralCodeButtonDisabled)
    }

    private var getReferralCodeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.moveToClaimReferralCodeScreen()
            }
        } label: {
            HStack(spacing: 4.22) {
                Text("Don't have a code?")

                HStack(spacing: 0) {
                    Text("Click here")
                        .appFont(.smallLabelBold)
                        .underline(true, pattern: .solid)
                        .foregroundStyle(Colors.whitePrimary)

                    Text(" to get peer code.")
                }
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
