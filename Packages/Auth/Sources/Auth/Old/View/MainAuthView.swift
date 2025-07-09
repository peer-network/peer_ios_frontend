//
//  MainAuthView.swift
//  Auth
//
//  Created by Артем Васин on 24.01.25.
//

import SwiftUI
import Environment
import DesignSystem
import Analytics

public struct MainAuthView: View {
    @Environment(\.analytics) private var analytics

    @AppStorage("first_launch", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var firstLaunch = true

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager
    @Environment(\.openURL) private var openURL
    
    private enum FocusedField {
        case loginEmail
        case loginPassword
        
        case registerEmail
        case registerUsername
        case registerPassword
        case registerReferralCode
    }
    
    @StateObject var viewModel: AuthViewModel
    
    @State private var showLoginPassword = false
    @State private var showRegisterPassword = false
    
    @FocusState private var focusedField: FocusedField?
    
    public init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Images.logoText
                        .frame(height: 56.8)
                        .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 27.21)
                    
                    Text("Almost like with any social media you can share the content you love, but with **Peer**, you earn on the side – no fame needed!")
                        .font(.customFont(weight: .light, size: .body))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Colors.whitePrimary)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                        .frame(height: 52.25)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Button {
                            focusedField = nil
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.formType = .login
                            }
                        } label: {
                            Text("login")
                                .textCase(.lowercase)
                                .bold(viewModel.formType == .login)
                                .contentShape(Rectangle())
                                .padding(.trailing, 20)
                        }
                        
                        Rectangle()
                            .frame(width: 1, height: 20.5)
                        
                        Button {
                            focusedField = nil
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.formType = .register
                            }
                        } label: {
                            Text("register")
                                .textCase(.lowercase)
                                .bold(viewModel.formType == .register)
                                .contentShape(Rectangle())
                                .padding(.leading, 20)
                        }
                    }
                    .font(.customFont(weight: .regular, size: .body))
                    .foregroundStyle(Colors.whitePrimary)

                    Spacer()
                        .frame(height: 25.5)
                    
                    switch viewModel.formType {
                        case .forgotPassword:
                            PasswordResetView()
                                .padding(.horizontal, 20)
                                .transition(.blurReplace())
                                .environmentObject(viewModel)
                        case .login:
                            loginFormView
                                .transition(.move(edge: .leading))
                        case .register:
                            registerFormView
                                .transition(.move(edge: .trailing))
                                .onFirstAppear {
                                    Task { @MainActor in
                                        try? await Task.sleep(for: .seconds(0.3))

                                        if let pasteboardString = UIPasteboard.general.string {
                                            if pasteboardString.hasPrefix("peer://invite/") {
                                                let referralCode = String(pasteboardString.split(separator: "/").last ?? "")
                                                viewModel.setReferralCode(referralCode)
                                            }
                                        }
                                    }
                                }
                    }
                    
                    Spacer()
                        .frame(maxHeight: .infinity)
                    
                    Button {
                        // TODO: No link for the privacy policy yet
                        openURL(URL(string: "https://www.freeprivacypolicy.com/live/02865c3a-79db-4baf-9ca1-7d91e2cf1724")!)
                    } label: {
                        Text("Privacy Policy")
                            .font(.customFont(weight: .regular, size: .footnote))
                            .underline(true, pattern: .solid)
                            .foregroundStyle(Colors.whitePrimary.opacity(0.6))
                    }
                    .padding(.bottom, 32)
                }
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
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
                .ignoresSafeArea()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            
        }
        .ignoresSafeArea(.keyboard)
        .environment(
          \.openURL,
           OpenURLAction { url in
               router.handle(url: url)
          })
        .onOpenURL(perform: { url in
            if url.scheme == "peer" && url.host == "invite",
               let referralCode = url.pathComponents.last {
                viewModel.setReferralCode(referralCode)
            }
        })
        .onFirstAppear { viewModel.apiService = apiManager.apiService }
        .sheet(isPresented: $firstLaunch, content: {
            NavigationStack {
                ScrollView {
                Text(
                    """
                    END USER LICENSE AGREEMENT
                    Last updated July 07, 2025
                    
                    
                    Peer Network is licensed to You (End-User) by Peer Network PSE UG, located and registered at Eisenacherstrasse 103a, Berlin, Berlin 10781, Germany ("Licensor"), for use only under the terms of this License Agreement.
                    
                    By downloading the Licensed Application from Apple's software distribution platform ("App Store"), and any update thereto (as permitted by this License Agreement), You indicate that You agree to be bound by all of the terms and conditions of this License Agreement, and that You accept this License Agreement. App Store is referred to in this License Agreement as "Services."
                    
                    The parties of this License Agreement acknowledge that the Services are not a Party to this License Agreement and are not bound by any provisions or obligations with regard to the Licensed Application, such as warranty, liability, maintenance and support thereof. Peer Network PSE UG, not the Services, is solely responsible for the Licensed Application and the content thereof.
                    
                    This License Agreement may not provide for usage rules for the Licensed Application that are in conflict with the latest Apple Media Services Terms and Conditions ("Usage Rules"). Peer Network PSE UG acknowledges that it had the opportunity to review the Usage Rules and this License Agreement is not conflicting with them.
                    
                    Peer Network when purchased or downloaded through the Services, is licensed to You for use only under the terms of this License Agreement. The Licensor reserves all rights not expressly granted to You. Peer Network is to be used on devices that operate with Apple's operating systems ("iOS" and "Mac OS").
                    
                    
                    TABLE OF CONTENTS
                    1. THE APPLICATION
                    2. SCOPE OF LICENSE
                    3. TECHNICAL REQUIREMENTS
                    4. MAINTENANCE AND SUPPORT
                    5. USE OF DATA
                    6. USER-GENERATED CONTRIBUTIONS
                    7. CONTRIBUTION LICENSE
                    8. LIABILITY
                    9. WARRANTY
                    10. PRODUCT CLAIMS
                    11. LEGAL COMPLIANCE
                    12. CONTACT INFORMATION
                    13. TERMINATION
                    14. THIRD-PARTY TERMS OF AGREEMENTS AND BENEFICIARY
                    15. INTELLECTUAL PROPERTY RIGHTS
                    16. APPLICABLE LAW
                    17. MISCELLANEOUS
                    
                    
                    1. THE APPLICATION
                    Peer Network ("Licensed Application") is a piece of software created to social media platform for creators — and customized for iOS mobile devices ("Devices"). It is used to earn money from your content.
                    
                    The Licensed Application is not tailored to comply with industry-specific regulations (Health Insurance Portability and Accountability Act (HIPAA), Federal Information Security Management Act (FISMA), etc.), so if your interactions would be subjected to such laws, you may not use this Licensed Application. You may not use the Licensed Application in a way that would violate the Gramm-Leach-Bliley Act (GLBA).
                    
                    2. SCOPE OF LICENSE
                    2.1  You are given a non-transferable, non-exclusive, non-sublicensable license to install and use the Licensed Application on any Devices that You (End-User) own or control and as permitted by the Usage Rules, with the exception that such Licensed Application may be accessed and used by other accounts associated with You (End-User, The Purchaser) via Family Sharing or volume purchasing.
                    
                    2.2  This license will also govern any updates of the Licensed Application provided by Licensor that replace, repair, and/or supplement the first Licensed Application, unless a separate license is provided for such update, in which case the terms of that new license will govern.
                    
                    2.3  You may not share or make the Licensed Application available to third parties (unless to the degree allowed by the Usage Rules, and with Peer Network PSE UG's prior written consent), sell, rent, lend, lease or otherwise redistribute the Licensed Application.
                    
                    2.4  You may not reverse engineer, translate, disassemble, integrate, decompile, remove, modify, combine, create derivative works or updates of, adapt, or attempt to derive the source code of the Licensed Application, or any part thereof (except with Peer Network PSE UG's prior written consent).
                    
                    2.5  You may not copy (excluding when expressly authorized by this license and the Usage Rules) or alter the Licensed Application or portions thereof. You may create and store copies only on devices that You own or control for backup keeping under the terms of this license, the Usage Rules, and any other terms and conditions that apply to the device or software used. You may not remove any intellectual property notices. You acknowledge that no unauthorized third parties may gain access to these copies at any time. If you sell your Devices to a third party, you must remove the Licensed Application from the Devices before doing so.
                    
                    2.6  Violations of the obligations mentioned above, as well as the attempt of such infringement, may be subject to prosecution and damages.
                    
                    2.7  Licensor reserves the right to modify the terms and conditions of licensing.
                    
                    2.8  Nothing in this license should be interpreted to restrict third-party terms. When using the Licensed Application, You must ensure that You comply with applicable third-party terms and conditions.
                    
                    3. TECHNICAL REQUIREMENTS
                    3.1  Licensor reserves the right to modify the technical specifications as it sees appropriate at any time.
                    
                    4. MAINTENANCE AND SUPPORT
                    4.1  The Licensor is solely responsible for providing any maintenance and support services for this Licensed Application. You can reach the Licensor at the email address listed in the App Store Overview for this Licensed Application.
                    
                    4.2  Peer Network PSE UG and the End-User acknowledge that the Services have no obligation whatsoever to furnish any maintenance and support services with respect to the Licensed Application.
                    
                    5. USE OF DATA
                    You acknowledge that Licensor will be able to access and adjust Your downloaded Licensed Application content and Your personal information, and that Licensor's use of such material and information is subject to Your legal agreements with Licensor and Licensor's privacy policy: https://www.freeprivacypolicy.com/live/02865c3a-79db-4baf-9ca1-7d91e2cf1724.
                    
                    You acknowledge that the Licensor may periodically collect and use technical data and related information about your device, system, and application software, and peripherals, offer product support, facilitate the software updates, and for purposes of providing other services to you (if any) related to the Licensed Application. Licensor may also use this information to improve its products or to provide services or technologies to you, as long as it is in a form that does not personally identify you.
                    
                    6. USER-GENERATED CONTRIBUTIONS
                    The Licensed Application may invite you to chat, contribute to, or participate in blogs, message boards, online forums, and other functionality, and may provide you with the opportunity to create, submit, post, display, transmit, perform, publish, distribute, or broadcast content and materials to us or in the Licensed Application, including but not limited to text, writings, video, audio, photographs, graphics, comments, suggestions, or personal information or other material (collectively, "Contributions"). Contributions may be viewable by other users of the Licensed Application and through third-party websites or applications. As such, any Contributions you transmit may be treated as non-confidential and non-proprietary. When you create or make available any Contributions, you thereby represent and warrant that:
                    
                    1. The creation, distribution, transmission, public display, or performance, and the accessing, downloading, or copying of your Contributions do not and will not infringe the proprietary rights, including but not limited to the copyright, patent, trademark, trade secret, or moral rights of any third party.
                    2. You are the creator and owner of or have the necessary licenses, rights, consents, releases, and permissions to use and to authorize us, the Licensed Application, and other users of the Licensed Application to use your Contributions in any manner contemplated by the Licensed Application and this License Agreement.
                    3. You have the written consent, release, and/or permission of each and every identifiable individual person in your Contributions to use the name or likeness or each and every such identifiable individual person to enable inclusion and use of your Contributions in any manner contemplated by the Licensed Application and this License Agreement.
                    4. Your Contributions are not false, inaccurate, or misleading.
                    5. Your Contributions are not unsolicited or unauthorized advertising, promotional materials, pyramid schemes, chain letters, spam, mass mailings, or other forms of solicitation.
                    6. Your Contributions are not obscene, lewd, lascivious, filthy, violent, harassing, libelous, slanderous, or otherwise objectionable (as determined by us).
                    7. Your Contributions do not ridicule, mock, disparage, intimidate, or abuse anyone.
                    8. Your Contributions are not used to harass or threaten (in the legal sense of those terms) any other person and to promote violence against a specific person or class of people.
                    9. Your Contributions do not violate any applicable law, regulation, or rule.
                    10. Your Contributions do not violate the privacy or publicity rights of any third party.
                    11. Your Contributions do not violate any applicable law concerning child pornography, or otherwise intended to protect the health or well-being of minors.
                    12. Your Contributions do not include any offensive comments that are connected to race, national origin, gender, sexual preference, or physical handicap.
                    13. Your Contributions do not otherwise violate, or link to material that violates, any provision of this License Agreement, or any applicable law or regulation.
                    
                    Any use of the Licensed Application in violation of the foregoing violates this License Agreement and may result in, among other things, termination or suspension of your rights to use the Licensed Application.
                    
                    7. CONTRIBUTION LICENSE
                    By posting your Contributions to any part of the Licensed Application or making Contributions accessible to the Licensed Application by linking your account from the Licensed Application to any of your social networking accounts, you automatically grant, and you represent and warrant that you have the right to grant, to us an unrestricted, unlimited, irrevocable, perpetual, non-exclusive, transferable, royalty-free, fully-paid, worldwide right, and license to host, use copy, reproduce, disclose, sell, resell, publish, broad cast, retitle, archive, store, cache, publicly display, reformat, translate, transmit, excerpt (in whole or in part), and distribute such Contributions (including, without limitation, your image and voice) for any purpose, commercial advertising, or otherwise, and to prepare derivative works of, or incorporate in other works, such as Contributions, and grant and authorize sublicenses of the foregoing. The use and distribution may occur in any media formats and through any media channels.
                    
                    This license will apply to any form, media, or technology now known or hereafter developed, and includes our use of your name, company name, and franchise name, as applicable, and any of the trademarks, service marks, trade names, logos, and personal and commercial images you provide. You waive all moral rights in your Contributions, and you warrant that moral rights have not otherwise been asserted in your Contributions.
                    
                    We do not assert any ownership over your Contributions. You retain full ownership of all of your Contributions and any intellectual property rights or other proprietary rights associated with your Contributions. We are not liable for any statements or representations in your Contributions provided by you in any area in the Licensed Application. You are solely responsible for your Contributions to the Licensed Application and you expressly agree to exonerate us from any and all responsibility and to refrain from any legal action against us regarding your Contributions.
                    
                    We have the right, in our sole and absolute discretion, (1) to edit, redact, or otherwise change any Contributions; (2) to recategorize any Contributions to place them in more appropriate locations in the Licensed Application; and (3) to prescreen or delete any Contributions at any time and for any reason, without notice. We have no obligation to monitor your Contributions.
                    
                    8. LIABILITY
                    8.1  Licensor's responsibility in the case of violation of obligations and tort shall be limited to intent and gross negligence. Only in case of a breach of essential contractual duties (cardinal obligations), Licensor shall also be liable in case of slight negligence. In any case, liability shall be limited to the foreseeable, contractually typical damages. The limitation mentioned above does not apply to injuries to life, limb, or health.
                    
                    8.2  Licensor takes no accountability or responsibility for any damages caused due to a breach of duties according to Section 2 of this License Agreement. To avoid data loss, You are required to make use of backup functions of the Licensed Application to the extent allowed by applicable third-party terms and conditions of use. You are aware that in case of alterations or manipulations of the Licensed Application, You will not have access to the Licensed Application.
                    
                    9. WARRANTY
                    9.1  Licensor warrants that the Licensed Application is free of spyware, trojan horses, viruses, or any other malware at the time of Your download. Licensor warrants that the Licensed Application works as described in the user documentation.
                    
                    9.2  No warranty is provided for the Licensed Application that is not executable on the device, that has been unauthorizedly modified, handled inappropriately or culpably, combined or installed with inappropriate hardware or software, used with inappropriate accessories, regardless if by Yourself or by third parties, or if there are any other reasons outside of Peer Network PSE UG's sphere of influence that affect the executability of the Licensed Application.
                    
                    9.3  You are required to inspect the Licensed Application immediately after installing it and notify Peer Network PSE UG about issues discovered without delay by email provided in Contact Information. The defect report will be taken into consideration and further investigated if it has been emailed within a period of one hundred eighty (180) days after discovery.
                    
                    9.4  If we confirm that the Licensed Application is defective, Peer Network PSE UG reserves a choice to remedy the situation either by means of solving the defect or substitute delivery.
                    
                    9.5  In the event of any failure of the Licensed Application to conform to any applicable warranty, You may notify the Services Store Operator, and Your Licensed Application purchase price will be refunded to You. To the maximum extent permitted by applicable law, the Services Store Operator will have no other warranty obligation whatsoever with respect to the Licensed Application, and any other losses, claims, damages, liabilities, expenses, and costs attributable to any negligence to adhere to any warranty.
                    
                    9.6  If the user is an entrepreneur, any claim based on faults expires after a statutory period of limitation amounting to twelve (12) months after the Licensed Application was made available to the user. The statutory periods of limitation given by law apply for users who are consumers.
                    
                    10. PRODUCT CLAIMS
                    Peer Network PSE UG and the End-User acknowledge that Peer Network PSE UG, and not the Services, is responsible for addressing any claims of the End-User or any third party relating to the Licensed Application or the End-User’s possession and/or use of that Licensed Application, including, but not limited to:
                    
                            
                    (i) product liability claims;
                       
                    (ii) any claim that the Licensed Application fails to conform to any applicable legal or regulatory requirement; and
                    
                    (iii) claims arising under consumer protection, privacy, or similar legislation, including in connection with Your Licensed Application’s use of the HealthKit and HomeKit.
                    
                    11. LEGAL COMPLIANCE
                    You represent and warrant that You are not located in a country that is subject to a US Government embargo, or that has been designated by the US Government as a "terrorist supporting" country; and that You are not listed on any US Government list of prohibited or restricted parties.
                    
                    12. CONTACT INFORMATION
                    For general inquiries, complaints, questions or claims concerning the Licensed Application, please contact:
                               
                    __________
                    Eisenacherstrasse 103a
                    Berlin, Berlin 10781
                    Germany
                    peernetworkpse@gmail.com
                    
                    13. TERMINATION
                    The license is valid until terminated by Peer Network PSE UG or by You. Your rights under this license will terminate automatically and without notice from Peer Network PSE UG if You fail to adhere to any term(s) of this license. Upon License termination, You shall stop all use of the Licensed Application, and destroy all copies, full or partial, of the Licensed Application.
                    
                    14. THIRD-PARTY TERMS OF AGREEMENTS AND BENEFICIARY
                    Peer Network PSE UG represents and warrants that Peer Network PSE UG will comply with applicable third-party terms of agreement when using Licensed Application.
                    
                    In Accordance with Section 9 of the "Instructions for Minimum Terms of Developer's End-User License Agreement," Apple's subsidiaries shall be third-party beneficiaries of this End User License Agreement and — upon Your acceptance of the terms and conditions of this License Agreement, Apple will have the right (and will be deemed to have accepted the right) to enforce this End User License Agreement against You as a third-party beneficiary thereof.
                    
                    15. INTELLECTUAL PROPERTY RIGHTS
                    Peer Network PSE UG and the End-User acknowledge that, in the event of any third-party claim that the Licensed Application or the End-User's possession and use of that Licensed Application infringes on the third party's intellectual property rights, Peer Network PSE UG, and not the Services, will be solely responsible for the investigation, defense, settlement, and discharge or any such intellectual property infringement claims.
                    
                    16. APPLICABLE LAW
                    This License Agreement is governed by the laws of Germany excluding its conflicts of law rules.
                    
                    17. MISCELLANEOUS
                    17.1  If any of the terms of this agreement should be or become invalid, the validity of the remaining provisions shall not be affected. Invalid terms will be replaced by valid ones formulated in a way that will achieve the primary purpose.
                                       
                    17.2  Collateral agreements, changes and amendments are only valid if laid down in writing. The preceding clause can only be waived in writing. 
                    """
                )
            }
                .navigationTitle("User agreement")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Agree") {
                            firstLaunch = false
                        }
                    }
                }
            }
            .interactiveDismissDisabled()
        })
        .trackScreen(AppScreen.auth)
    }
    
    // MARK: - Login Form View
    
    private var loginFormView: some View {
        VStack(spacing: 0) {
            loginEmailTextField
                .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 10)
            
            loginPasswordTextField
                .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 20)
            
            if !viewModel.loginError.isEmpty {
                Text(viewModel.loginError)
                    .font(.customFont(weight: .regular, size: .footnote))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Colors.warning)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                    .frame(height: 20)
            }
            
            loginButton
                .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 20)
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.formType = .forgotPassword
                }
            } label: {
                Text("Forgot password")
                    .font(.customFont(weight: .regular, style: .footnote))
                    .underline(true, pattern: .solid)
                    .foregroundStyle(Colors.whitePrimary.opacity(0.6))
                    .contentShape(Rectangle())
            }
        }
    }
    
    private var loginEmailTextField: some View {
        ValidatedTextField(
            placeholder: "E-mail",
            text: $viewModel.loginEmail,
            type: .default,
            icon: viewModel.isValidEmail(viewModel.loginEmail) ? Icons.checkmarkCircle : Icons.xCircle,
            errorMessage: "Invalid email format.",
            isValid: viewModel.isValidEmail(viewModel.loginEmail),
            focusedField: $focusedField,
            field: .loginEmail
        )
        .submitLabel(.next)
        .onSubmit {
            focusedField = .loginPassword
        }
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            focusedField = .loginEmail
        }
    }
    
    private var loginPasswordTextField: some View {
        FormTextField(
            placeholder: "Password",
            text: $viewModel.loginPassword,
            type: showLoginPassword ? .default : .secured,
            icon: viewModel.loginPassword.isEmpty ? nil : (showLoginPassword ? Icons.eyeSlash : Icons.eye),
            onIconClick: {
                showLoginPassword.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .loginPassword
                }
            }
        )
        .focused($focusedField, equals: .loginPassword)
        .submitLabel(.done)
        .textContentType(.password)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            focusedField = .loginPassword
        }
    }
    
    // MARK: - Register Form View
    
    private var registerFormView: some View {
        VStack(spacing: 0) {
            registerEmailTextField
                .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 10)
            
            registerUsernameTextField
                .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 10)
            
            registerPasswordTextField
                .padding(.horizontal, 20)
            
            if viewModel.passwordStrength != .empty {
                Spacer()
                    .frame(height: 10)
                
                PasswordStrengthBarsView(strength: viewModel.passwordStrength)
                    .padding(.horizontal, 35)
            }

            Spacer()
                .frame(height: 10)

            registerReferralTextField
                .padding(.horizontal, 20)

            if !viewModel.regError.isEmpty {
                Spacer()
                    .frame(height: 20)
                
                Text(viewModel.regError)
                    .font(.customFont(weight: .regular, size: .footnote))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Colors.warning)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
                .frame(height: 20)
            
            registerButton
                .padding(.horizontal, 20)
        }
    }
    
    private var registerEmailTextField: some View {
        ValidatedTextField(
            placeholder: "E-mail",
            text: $viewModel.regEmail,
            type: .default,
            icon:  viewModel.isValidEmail(viewModel.regEmail) ? Icons.checkmarkCircle : Icons.xCircle,
            errorMessage: "Invalid email format.",
            isValid: viewModel.isValidEmail(viewModel.regEmail),
            focusedField: $focusedField,
            field: .registerEmail
        )
        .submitLabel(.next)
        .onSubmit {
            focusedField = .registerUsername
        }
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            focusedField = .registerEmail
        }
        .onChange(of: viewModel.regEmail) {
            if viewModel.regEmail.count > 60 {
                viewModel.regEmail = String(viewModel.regEmail.prefix(60))
            }
        }
    }
    
    private var registerUsernameTextField: some View {
        ValidatedTextField(
            placeholder: "Username",
            text: $viewModel.regUsername,
            type: .default,
            icon: viewModel.isValidUsername(viewModel.regUsername) ? Icons.checkmarkCircle : Icons.xCircle,
            hint: "3-23 characters, letters/numbers/_ only",
            errorMessage: "Invalid username format.",
            isValid: viewModel.isValidUsername(viewModel.regUsername),
            focusedField: $focusedField,
            field: .registerUsername
        )
        .submitLabel(.next)
        .onSubmit {
            focusedField = .registerPassword
        }
        .textContentType(.username)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            focusedField = .registerUsername
        }
        .onChange(of: viewModel.regUsername) {
            if viewModel.regUsername.count > 23 {
                viewModel.regUsername = String(viewModel.regUsername.prefix(23))
            }
        }
    }
    
    private var registerPasswordTextField: some View {
        FormTextField(
            placeholder: "Password",
            text: $viewModel.regPassword,
            type: showRegisterPassword ? .default : .secured,
            icon: viewModel.regPassword.isEmpty ? nil : (showRegisterPassword ? Icons.eyeSlash : Icons.eye),
            onIconClick: {
                showRegisterPassword.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .registerPassword
                }
            }
        )
        .focused($focusedField, equals: .registerPassword)
        .submitLabel(.done)
        .textContentType(.password) // .newPassword freezes the UI
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            focusedField = .registerPassword
        }
    }

    private var registerReferralTextField: some View {
        FormTextField(placeholder: "Referral code (optional)", text: $viewModel.regReferralCode, type: .default)
            .focused($focusedField, equals: .registerReferralCode)
            .submitLabel(.done)
            .keyboardType(.asciiCapable)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onTapGesture {
                focusedField = .registerReferralCode
            }
    }

    private var loginButton: some View {
        Button("Login") {
            Task {
                await viewModel.login()
            }
        }
        .buttonStyle(TargetButtonStyle())
    }
    
    private var registerButton: some View {
        Button("Register") {
            Task {
                let result = await viewModel.register()
                if result == true {
                    showPopup(
                        text: "Registration was successful! You can now log in.",
                        icon: Icons.checkmarkCircle
                        // should be red
                    )
                    viewModel.formType = .login
                    analytics.track(AuthEvent.signUp)
                }
            }
        }
        .buttonStyle(TargetButtonStyle())
    }
    
    private struct ValidatedTextField: View {
        let placeholder: String
        @Binding var text: String
        let type: FormTextField.TextFieldType
        var icon: Image? = nil
        var onIconClick: (() -> Void)? = nil
        var hint: String? = nil
        let errorMessage: String
        let isValid: Bool
        @FocusState.Binding var focusedField: FocusedField?
        let field: FocusedField
        
        /// This property decides which text (if any) will be displayed below the TextField.
        private var helperText: String? {
            if focusedField == field {
                // If focused, show the hint
                if let hint {
                    return hint
                } else {
                    return nil
                }
            } else if !text.isEmpty, !isValid {
                // If not empty but invalid, show error
                return errorMessage
            } else {
                // Else no extra text
                return nil
            }
        }
        
        /// If the displayed text is the error message, style it with .warning
        private var isError: Bool {
            helperText == errorMessage
        }
        
        var body: some View {
            VStack(alignment: .center, spacing: 10) {
                FormTextField(
                    placeholder: placeholder,
                    text: $text,
                    type: type,
                    icon: (focusedField != field && !text.isEmpty) ? icon : nil,
                    onIconClick: onIconClick
                )
                .focused($focusedField, equals: field)
                
                if let helperText {
                    Text(helperText)
                        .font(.customFont(weight: .regular, size: .footnote))
                        .foregroundStyle(isError ? Colors.warning : Colors.whitePrimary.opacity(0.6))
                }
            }
        }
    }
}

//#Preview {
//    let authManager = AuthManager()
//    let apiService = APIServiceStub()
//    
//    MainAuthView(viewModel: AuthViewModel(authManager: authManager))
//        .environmentObject(APIServiceManager(.mock))
//}
