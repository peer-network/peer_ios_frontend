//
//  PasswordResetView.swift
//  Auth
//
//  Created by Artem Vasin on 23.05.25.
//

import SwiftUI
import Environment
import DesignSystem

struct PasswordResetView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    enum ResetState {
        case enterEmail
        case enterCode
        case enderNewPassword
    }
    @State private var resetState: ResetState = .enterEmail

    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var passwordResetViewModel = PasswordResetViewModel()

    @State private var email: String = ""
    @State private var code: String = ""

    @FocusState private var isEmailFocused: Bool
    @FocusState private var isConfirmationCodeFocused: Bool
    @FocusState private var isNewPasswordFocused: Bool

    @State private var showNewPassword = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot password")
                .font(.customFont(weight: .regular, style: .title1))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            switch resetState {
                case .enterEmail:
                    enterEmailView
                case .enterCode:
                    enterCodeView
                case .enderNewPassword:
                    enterNewPasswordView
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .onFirstAppear {
            passwordResetViewModel.apiService = apiManager.apiService
        }
    }

    @ViewBuilder
    private var enterEmailView: some View {
        emailTextField
            .onFirstAppear {
                isEmailFocused = true
            }

        if !passwordResetViewModel.error.isEmpty {
            Text(passwordResetViewModel.error)
                .font(.customFont(weight: .regular, size: .footnote))
                .multilineTextAlignment(.center)
                .foregroundStyle(Colors.warning)
                .fixedSize(horizontal: false, vertical: true)
        }

        Button("Reset password") {
            Task {
                let result = await passwordResetViewModel.requestPasswordReset(email: email)
                if result == true {
                    withAnimation {
                        passwordResetViewModel.error = ""
                        resetState = .enterCode
                    }
                }
            }
        }
        .buttonStyle(TargetButtonStyle())

        Button {
            withAnimation {
                passwordResetViewModel.error = ""
                resetState = .enterCode
            }
        } label: {
            Text("Already have a code")
                .foregroundStyle(Colors.whiteSecondary)
                .font(.customFont(weight: .regular, style: .footnote))
                .underline(true, pattern: .solid)
        }
    }

    @ViewBuilder
    private var enterCodeView: some View {
        Text("We sent a code to your email. Please, enter the code to change your password.")
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)

        confirmationCodeTextField
            .onFirstAppear {
                isConfirmationCodeFocused = true
            }

        if !passwordResetViewModel.error.isEmpty {
            Text(passwordResetViewModel.error)
                .font(.customFont(weight: .regular, size: .footnote))
                .multilineTextAlignment(.center)
                .foregroundStyle(Colors.warning)
                .fixedSize(horizontal: false, vertical: true)
        }

        Button("Continue") {
            withAnimation {
                passwordResetViewModel.error = ""
                resetState = .enderNewPassword
            }
        }
        .buttonStyle(TargetButtonStyle())
    }

    @ViewBuilder
    private var enterNewPasswordView: some View {
        newPasswordTextField

//        if passwordResetViewModel.passwordStrength != .empty {
//            PasswordStrengthBarsView(strength: passwordResetViewModel.passwordStrength)
//                .padding(.horizontal, 15)
//                .padding(.vertical, -10)
//        }

        if !passwordResetViewModel.error.isEmpty {
            Text(passwordResetViewModel.error)
                .font(.customFont(weight: .regular, size: .footnote))
                .multilineTextAlignment(.center)
                .foregroundStyle(Colors.warning)
                .fixedSize(horizontal: false, vertical: true)
        }

        Button("Save") {
            Task {
                let result = await passwordResetViewModel.resetPassword(token: code, newPassword: passwordResetViewModel.newPassword)

                if result == true {
                    showPopup(text: "Successfully changed password.")
                    withAnimation {
                        authVM.formType = .login
                    }
                    resetData()
                }
            }
        }
        .buttonStyle(TargetButtonStyle())
    }

    private func resetData() {
        email = ""
        code = ""
        passwordResetViewModel.newPassword = ""
        passwordResetViewModel.error = ""
        resetState = .enterEmail
    }

    private var emailTextField: some View {
        ValidatedTextField(
            placeholder: "E-mail",
            text: $email,
            type: .default,
            icon: passwordResetViewModel.isValidEmail(email) ? Icons.checkmarkCircle : Icons.xCircle,
            errorMessage: "Invalid email format.",
            isValid: passwordResetViewModel.isValidEmail(email),
            focused: $isEmailFocused
        )
        .submitLabel(.done)
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isEmailFocused = true
        }
    }

    private var confirmationCodeTextField: some View {
        FormTextField(
            placeholder: "Code",
            text: $code,
            type: .default,
            icon: nil
        )
        .focused($isConfirmationCodeFocused)
        .submitLabel(.done)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isConfirmationCodeFocused = true
        }
    }

    private var newPasswordTextField: some View {
        FormTextField(
            placeholder: "New password",
            text: $passwordResetViewModel.newPassword,
            type: showNewPassword ? .default : .secured,
            icon: passwordResetViewModel.newPassword.isEmpty ? nil : (showNewPassword ? Icons.eyeSlash : Icons.eye),
            onIconClick: {
                showNewPassword.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isNewPasswordFocused = true
                }
            }
        )
        .focused($isNewPasswordFocused)
        .submitLabel(.done)
        .textContentType(.password) // .newPassword freezes the UI
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isNewPasswordFocused = true
        }
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
        @FocusState.Binding var focused: Bool

        /// This property decides which text (if any) will be displayed below the TextField.
        private var helperText: String? {
            if focused {
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
            VStack(alignment: .center, spacing: 15) {
                FormTextField(
                    placeholder: placeholder,
                    text: $text,
                    type: type,
                    icon: (!focused && !text.isEmpty) ? icon : nil,
                    onIconClick: onIconClick
                )
                .focused($focused)

                if let helperText {
                    Text(helperText)
                        .font(.customFont(weight: .regular, size: .footnote))
                        .foregroundStyle(isError ? Colors.warning : Colors.whitePrimary.opacity(0.6))
                }
            }
        }
    }
}
