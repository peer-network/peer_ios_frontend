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

    private enum FocusField: Hashable {
        case referralCode
    }

    @FocusState private var focusedField: FocusField?

    var body: some View {
        pageContent
    }

    @ViewBuilder
    private var pageContent: some View {
        handShakeAnimation
            .padding(.bottom, 27)

        titleText
            .padding(.bottom, 4)

        descriptionText
            .padding(.bottom, 24)

        codeTextField
            .padding(.bottom, 15)

        useCodeButton
    }

    private var handShakeAnimation: some View {
        LottieView(animation: .handShake)
            .frame(width: 119, height: 119)
    }

    private var titleText: some View {
        Text("Claim Your Invitation")
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text("Earning starts the moment you enter this.")
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
    private var useCodeButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Use this code")

        StateButton(config: config) {
            focusedField = nil
            
            withAnimation(.easeInOut(duration: 0.2)) {
                authVM.moveToRegisterScreen()
            }
        }
    }
}
