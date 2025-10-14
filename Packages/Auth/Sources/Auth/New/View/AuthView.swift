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
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var router = Router()
    @StateObject private var authVM: AuthorizationViewModel

    @State private var singlePadding: CGFloat = 0
    var isBottomSectionFit: Bool {
        singlePadding >= (30 * 2 + 40)
    }

    @State private var keyboardHeight: CGFloat = 0

    public init(viewModel: AuthorizationViewModel) {
        _authVM = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: singlePadding)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .topLeading) {
                            if authVM.showBackButton {
                                backButton {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        authVM.backButtonTapped()
                                    }
                                }
                            }
                        }

                    pageContent
                        .padding(.horizontal, 25)
                        .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                            singlePadding = abs(geo.frame(in: .global).height - height) / 2
                        }
                    
                    if !isBottomSectionFit {
                        bottomSectionView
                            .padding(.top, singlePadding)
                            .animation(nil)
                    }
                    
                    Color.clear
                        .frame(height: singlePadding)
                        .overlay(alignment: .bottom) {
                            if isBottomSectionFit {
                                bottomSectionView
                                    .animation(nil)
                                    .padding(.bottom, 30)
                            }
                        }

                    Spacer()
                        .frame(height: keyboardHeight)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background {
            backgroundView
                .ignoresSafeArea()
        }
        .keyboardHeight($keyboardHeight)
        .ignoresSafeArea(.keyboard)
        .environment(
            \.openURL,
             OpenURLAction { url in
                 router.handle(url: url)
             })
        .environmentObject(authVM)
        .fullScreenCover(isPresented: $authVM.showRegistrationSuccessCover) {
            SuccessView(title: "Welcome to peer", description: "Your account is ready! Start exploring and earn your first token today.") {
                await authVM.successCoverContinueButtonTapped()
            }
            .background {
                backgroundView
                    .ignoresSafeArea()
            }
        }
        .onFirstAppear { authVM.apiService = apiManager.apiService }
    }
    
    private var pageContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch authVM.formType {
                case .login:
                    LoginView()
                        .transition(.blurReplace)
                        .onAppear {
                            authVM.clearAllButLoginFields()
                        }
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
            .padding(.vertical, 10)
            .contentShape(.rect)
        }
    }
    
    private var privacyPolicyButton: some View {
        Button {
            openURL(URL(string: "https://peerapp.de/privacy.html")!)
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
}








struct KeyboardProvider: ViewModifier {

    var keyboardHeight: Binding<CGFloat>

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

                self.keyboardHeight.wrappedValue = keyboardRect.height

            }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                         perform: { _ in
                self.keyboardHeight.wrappedValue = 0
            })
    }
}


public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
}
