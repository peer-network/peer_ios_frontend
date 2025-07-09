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

    @FocusState private var focusedField: FocusField?

    var body: some View {
        pageContent
    }

    @ViewBuilder
    private var pageContent: some View {
        confettiAnimation
            .padding(.bottom, 27)

        welcomeText
            .padding(.bottom, 4)

        descriptionText
            .padding(.bottom, 24)

        codeTextField
            .padding(.bottom, 15)

        verifyButton
            .padding(.bottom, 24)

        getReferralCodeButton
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var confettiAnimation: some View {
        LottieView(animation: .confetti)
            .frame(width: 119, height: 119)
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
        DataInputTextField(text: $authVM.referralCode, placeholder: "Referral code", maxLength: 999, focusState: $focusedField, focusEquals: .referralCode)
            .submitLabel(.done)
    }

    @ViewBuilder
    private var verifyButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Verify")

        AsyncStateButton(config: config) {
            try? await Task.sleep(for: .seconds(3))
        }
    }

    private var getReferralCodeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.moveToClaimReferralCodeScreen()
            }
        } label: {
            HStack(spacing: 0) {
                Text("Don't have a code? ")

                Text("Click here")
                    .appFont(.smallLabelBold)
                    .underline(true, pattern: .solid)
                    .foregroundStyle(Colors.whitePrimary)

                Text(" to get peer code.")
            }
            .appFont(.smallLabelRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var privacyPolicyAgreementAndVersionStack: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("By continuing, you agree to")
                .foregroundStyle(Colors.whitePrimary)

            Button {
                //
            } label: {
                Text("Privacy Policy.")
                    .foregroundStyle(Colors.hashtag)
            }
        }
        .appFont(.smallLabelRegular)
    }
}
