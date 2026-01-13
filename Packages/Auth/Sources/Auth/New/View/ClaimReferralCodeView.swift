//
//  ClaimReferralCodeView.swift
//  Auth
//
//  Created by Artem Vasin on 24.06.25.
//

import SwiftUI
import DesignSystem

struct ClaimReferralCodeView: View {
    @EnvironmentObject private var authVM: AuthorizationViewModel

    private let companyReferralCode = "85d5f836-b1f5-4c4e-9381-1b058e13df93"

    private enum FocusField: Hashable {
        case referralCode
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

        useCodeButton
    }

    private var titleText: some View {
        Text("Claim your invitation")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("Earning starts the moment you enter this magic code.")
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var codeTextField: some View {
        DataInputTextField(
            leadingIcon: IconsNew.referral,
            text: .constant(companyReferralCode),
            placeholder: "Referral code",
            maxLength: 999,
            isEditable: false,
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
    private var useCodeButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Use this code")

        StateButton(config: config) {
            focusedField = nil
            
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.referralCode = companyReferralCode
                authVM.moveToRegisterScreen()
            }
        }
    }
}
