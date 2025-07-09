//
//  AuthView.swift
//  Auth
//
//  Created by Artem Vasin on 24.06.25.
//

import SwiftUI
import DesignSystem
import Environment

public struct AuthView: View {
    @Environment(\.openURL) private var openURL
    
    @StateObject private var router = Router()
    @StateObject private var authVM = AuthorizationViewModel()
    
    @State private var singlePadding: CGFloat = 0
    var isBottomSectionFit: Bool {
        singlePadding >= (30 * 2 + 40)
    }
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: singlePadding)
                    
                    pageContent
                        .padding(.horizontal, 25)
                        .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                            singlePadding = abs(geo.frame(in: .global).height - height) / 2
                        }
                    
                    if !isBottomSectionFit {
                        bottomSectionView
                            .padding(.top, singlePadding)
                    }
                    
                    Color.clear
                        .frame(height: singlePadding)
                        .overlay(alignment: .bottom) {
                            if isBottomSectionFit {
                                bottomSectionView
                                    .padding(.bottom, 30)
                            }
                        }
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .overlay(alignment: .topLeading) {
                if authVM.showBackButton {
                    backButton {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            authVM.backButtonTapped()
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .background {
            backgroundView
                .ignoresSafeArea()
        }
        .environment(
            \.openURL,
             OpenURLAction { url in
                 router.handle(url: url)
             })
        .overlay {
            if authVM.showAgeConfirmationPopup {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        authVM.showAgeConfirmationPopup = false
                    }
                
                ageConfirmationPopup
                    .shadow(color: .black.opacity(0.5), radius: 50, x: 0, y: -10)
                    .padding(.horizontal, 30)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if authVM.showAgeNotEnoughPopup {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        authVM.showAgeNotEnoughPopup = false
                    }
                
                ageIsNotEnoughtPopup
                    .shadow(color: .black.opacity(0.5), radius: 50, x: 0, y: -10)
                    .padding(.horizontal, 30)
            }
        }
        .environmentObject(authVM)
    }
    
    private var pageContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch authVM.formType {
                case .login:
                    LoginView()
                        .transition(.blurReplace)
                case .referralCode:
                    ReferralCodeView()
                        .transition(.blurReplace)
                case .noReferralCode:
                    ClaimReferralCodeView()
                        .transition(.blurReplace)
                case .register:
                    RegisterView()
                        .transition(.blurReplace)
                case .forgotPasswordEmail:
                    ResetPasswordView()
                        .transition(.blurReplace)
                case .forgotPasswordCode:
                    ResetPasswordCodeView()
                        .transition(.blurReplace)
                case .forgotPasswordNewPass:
                    ResetPasswordNewPassView()
                        .transition(.blurReplace)
            }
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            Colors.textActive
            
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                
                // MARK: - First Glow
                let glow1Width  = w * (347 / 393)
                let glow1Height = glow1Width * (318 / 347)
                
                Ellipse()
                    .frame(width: glow1Width, height: glow1Height)
                    .foregroundStyle(Colors.glowBlue.opacity(0.19))
                    .blur(radius: 50)
                    .offset(
                        x: w * (141 / 393),
                        y: -(glow1Height - (0.047 * h))
                    )
                
                // MARK: - Second Glow
                let glow2Width  = w * (530 / 393)
                let glow2Height = glow2Width * (342 / 530)
                
                Ellipse()
                    .frame(width: glow2Width, height: glow2Height)
                    .foregroundStyle(Colors.glowBlue.opacity(0.56))
                    .blur(radius: 100)
                    .offset(
                        x: -(glow2Width * (50 / 530)),
                        y: h + (0.0317 * h)
                    )
            }
        }
    }
    
    private func backButton(_ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 11) {
                IconsNew.arrowRight
                    .iconSize(width: 14)
                    .rotationEffect(.degrees(180))
                
                Text("Back")
            }
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .padding(.horizontal, 25)
            .contentShape(.rect)
        }
    }
    
    private var privacyPolicyButton: some View {
        Button {
            openURL(URL(string: "https://www.freeprivacypolicy.com/live/02865c3a-79db-4baf-9ca1-7d91e2cf1724")!)
        } label: {
            Text("Privacy Policy")
                .underline(true, pattern: .solid)
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)
        }
    }
    
    private var versionLabel: some View {
        Text("Version 1.0.0 build 1")
            .appFont(.smallLabelRegular)
            .foregroundStyle(Colors.whitePrimary)
            .opacity(0.2)
    }
    
    private var bottomSectionView: some View {
        VStack(spacing: 10) {
            privacyPolicyButton
            
            versionLabel
        }
    }
    
    private var ageConfirmationPopup: some View {
        VStack(spacing: 20) {
            IconsNew.ageRestriction
                .iconSize(height: 54)
                .foregroundStyle(Colors.redAccent)
            
            Text("You must be 18+ to proceed. By continuing, you confirm your eligibility.")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whitePrimary)
            
            HStack(spacing: 10) {
                // TODO: Actually need to rename this button since it is not State any more
                let config1 = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "No, I’m Under 18")
                StateButton(config: config1) {
                    authVM.underAgeTapped()
                }
                
                let config2 = StateButtonConfig(buttonSize: .small, buttonType: .alert, title: "I Am 18+")
                StateButton(config: config2) {
                    //
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
    
    private var ageIsNotEnoughtPopup: some View {
        VStack(spacing: 20) {
            IconsNew.ageRestriction
                .iconSize(height: 54)
                .foregroundStyle(Colors.redAccent)
            
            VStack(spacing: 0) {
                Text("Age requirement are not met!")
                    .appFont(.smallLabelBold)
                Text("Per our Terms of Service, this application is restricted to users aged 18 and above.")
                    .appFont(.smallLabelRegular)
            }
            .foregroundStyle(Colors.whitePrimary)
            
            HStack(spacing: 10) {
                // TODO: Actually need to rename this button since it is not State any more
                let config1 = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Dismiss")
                StateButton(config: config1) {
                    authVM.dismissAgeConfirmationTapped()
                }
                
                let config2 = StateButtonConfig(buttonSize: .small, buttonType: .alert, title: "Read Policy")
                StateButton(config: config2) {
                    openURL(URL(string: "https://www.freeprivacypolicy.com/live/02865c3a-79db-4baf-9ca1-7d91e2cf1724")!)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}
