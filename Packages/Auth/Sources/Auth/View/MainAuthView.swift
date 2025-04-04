//
//  MainAuthView.swift
//  Auth
//
//  Created by Артем Васин on 24.01.25.
//

import SwiftUI
import Environment
import DesignSystem

public struct MainAuthView: View {
    @EnvironmentObject private var router: Router
    @Environment(\.openURL) private var openURL
    
    private enum FocusedField {
        case loginEmail
        case loginPassword
        
        case registerEmail
        case registerUsername
        case registerPassword
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
                        .foregroundStyle(Color.white)
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
                    .foregroundStyle(Color.white)
                    
                    Spacer()
                        .frame(height: 25.5)
                    
                    switch viewModel.formType {
                        case .login:
                            loginFormView
                                .transition(.move(edge: .leading))
                        case .register:
                            registerFormView
                                .transition(.move(edge: .trailing))
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
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                    .padding(.bottom, 32)
                }
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                ZStack {
                    Color.backgroundDark
                    
                    GeometryReader { proxy in
                        let w = proxy.size.width
                        let h = proxy.size.height
                        
                        // MARK: - First Glow
                        let glow1Width  = w * (347 / 393)
                        let glow1Height = glow1Width * (318 / 347)
                        
                        Ellipse()
                            .frame(width: glow1Width, height: glow1Height)
                            .foregroundStyle(Color.glowBlue.opacity(0.19))
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
                            .foregroundStyle(Color.glowBlue.opacity(0.56))
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
                Text("Something went wrong. Please, try again")
                    .font(.customFont(weight: .regular, size: .footnote))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.warning)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 20)
            }
            
            loginButton
                .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 20)
            
            Button {
                // TODO: Not implemented in the API
            } label: {
                Text("Forgot password")
                    .font(.customFont(weight: .regular, size: .footnote))
                    .underline(true, pattern: .solid)
                    .foregroundStyle(Color.white.opacity(0.6))
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
            errorMessage: "Invalid email format",
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
            
            if !viewModel.regError.isEmpty {
                Spacer()
                    .frame(height: 20)
                
                Text("Something went wrong. Please, try again")
                    .font(.customFont(weight: .regular, size: .footnote))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.warning)
                    .padding(.horizontal, 20)
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
            errorMessage: "Invalid email format",
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
            errorMessage: "Invalid username format",
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
                        .foregroundStyle(isError ? Color.warning : Color.white.opacity(0.6))
                }
            }
        }
    }
}

public extension MainAuthView {
    
}

#Preview {
    let authManager = AuthManager()
    let apiService = APIServiceStub()
    
    MainAuthView(viewModel: AuthViewModel(authManager: authManager, apiService: apiService))
}
