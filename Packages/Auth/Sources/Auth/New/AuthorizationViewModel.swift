//
//  AuthorizationViewModel.swift
//  Auth
//
//  Created by Artem Vasin on 19.06.25.
//

import SwiftUI
import Models
import Environment

@MainActor
public final class AuthorizationViewModel: ObservableObject {
    unowned var apiService: APIService!
    private var authManager: AuthManager

    enum FormType {
        case login
        case referralCode
        case noReferralCode
        case register
        case forgotPasswordEmail
        case forgotPasswordCode
        case forgotPasswordNewPass
    }

    @Published private var navigationStack: [FormType] = []

    // MARK: Login properties
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var loginError = ""

    // MARK: Referral code properties
    @Published var referralCode = ""
    @Published var referralError = ""

    // MARK: Register properties
    @Published var regEmail = ""
    @Published var regUsername = ""
    @Published var regPassword = ""
    @Published var regPasswordRepeat = ""
    @Published private(set) var regPasswordStrength: PasswordEvaluation?
    @Published var agreedToPrivacyPolicy = false
    @Published var agreedToEULA = false
    @Published var regError = ""

    // MARK: Register properties
    @Published var forgotPasswordEmail = ""
    @Published var forgotPasswordCode = ""
    @Published var forgotPasswordNewPass = ""
    @Published var forgotPasswordRepeatPass = ""
    @Published private(set) var forgotPasswordStrength: PasswordEvaluation?
    @Published var forgotPasswordErrorEmail = ""
    @Published var forgotPasswordErrorResendEmail = ""
    @Published var forgotPasswordErrorBadCode = ""

    @Published var showRegistrationSuccessCover = false
    private var registrationSuccessEmail = ""
    private var registrationSuccessPassword = ""

    var formType: FormType {
        navigationStack.last ?? .login
    }

    var isLoginButtonDisabled: Bool {
        loginEmail.isEmpty || loginPassword.isEmpty
    }

    var isVerifyReferralCodeButtonDisabled: Bool {
        referralCode.isEmpty
    }

    var isRegisterButtonDisabled: Bool {
        if regEmail.isEmpty || regUsername.isEmpty || regPassword.isEmpty || regPasswordRepeat.isEmpty || !agreedToEULA || !agreedToPrivacyPolicy {
            return true
        }

        guard let regPasswordStrength else { return true }

        if regPasswordStrength.unmetRequirements.count > 0 {
            return true
        }

        return false
    }

    var isSendResetCodeButtonDisabled: Bool {
        forgotPasswordEmail.isEmpty
    }

    var isVerifyResetCodeButtonDisabled: Bool {
        forgotPasswordCode.isEmpty
    }

    var isUpdatePasswordButtonDisabled: Bool {
        if forgotPasswordNewPass.isEmpty || forgotPasswordRepeatPass.isEmpty {
            return true
        }

        guard let forgotPasswordStrength else { return true }

        if forgotPasswordStrength.unmetRequirements.count > 0 {
            return true
        }

        return false
    }

    var showBackButton: Bool {
        navigationStack.count > 0
    }

    public init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func moveToReferralCodeScreen() {
        navigationStack.append(.referralCode)
    }

    func moveToClaimReferralCodeScreen() {
        navigationStack.append(.noReferralCode)
    }

    func moveToRegisterScreen() {
        navigationStack.append(.register)
    }

    func moveToForgotPasswordScreen() {
        navigationStack.append(.forgotPasswordEmail)
    }

    func moveToForgotPasswordCodeScreen() {
        navigationStack.append(.forgotPasswordCode)
    }

    func moveToForgotPasswordNewPassScreen() {
        navigationStack.append(.forgotPasswordNewPass)
    }

    func backButtonTapped() {
        guard navigationStack.count > 0 else { return }
        navigationStack.removeLast()
    }

    func clearErrors() {
        loginError = ""
        regError = ""
        referralError = ""
        forgotPasswordErrorEmail = ""
        forgotPasswordErrorResendEmail = ""
        forgotPasswordErrorBadCode = ""
    }

    func clearAllButLoginFields() {
        loginError = ""
        referralCode = ""
        referralError = ""
        regEmail = ""
        regUsername = ""
        regPassword = ""
        regPasswordRepeat = ""
        regPasswordStrength = nil
        agreedToPrivacyPolicy = false
        agreedToEULA = false
        regError = ""
        forgotPasswordEmail = ""
        forgotPasswordCode = ""
        forgotPasswordNewPass = ""
        forgotPasswordRepeatPass = ""
        forgotPasswordStrength = nil
        forgotPasswordErrorEmail = ""
        forgotPasswordErrorResendEmail = ""
        forgotPasswordErrorBadCode = ""
    }

    func clearAllFields() {
        loginEmail = ""
        loginPassword = ""
        loginError = ""
        referralCode = ""
        referralError = ""
        regEmail = ""
        regUsername = ""
        regPassword = ""
        regPasswordRepeat = ""
        regPasswordStrength = nil
        agreedToPrivacyPolicy = false
        agreedToEULA = false
        regError = ""
        forgotPasswordEmail = ""
        forgotPasswordCode = ""
        forgotPasswordNewPass = ""
        forgotPasswordRepeatPass = ""
        forgotPasswordStrength = nil
        forgotPasswordErrorEmail = ""
        forgotPasswordErrorResendEmail = ""
        forgotPasswordErrorBadCode = ""
    }
}

// MARK: - Login

extension AuthorizationViewModel {
    func loginButtonTapped() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            clearErrors()
        }

        do {
            try await authManager.login(email: loginEmail, password: loginPassword)
        } catch {
            withAnimation(.easeInOut(duration: 0.2)) {
                loginError = error.userFriendlyMessage
            }
        }
    }
}

// MARK: - Registration

extension AuthorizationViewModel {
    func evaluateRegisterPasswordStrength() {
        if regPassword.isEmpty {
            regPasswordStrength = nil
        } else {
            regPasswordStrength = PasswordPolicy.evaluate(regPassword)
        }
    }

    func verifyReferralCodeButtonTapped() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            clearErrors()
        }

        let result = await apiService.verifyReferralCode(code: referralCode)

        switch result {
            case .success:
                moveToRegisterScreen()
            case .failure(let apiError):
                withAnimation(.easeInOut(duration: 0.2)) {
                    referralError = apiError.userFriendlyMessage
                }
        }
    }

    func registerButtonTapped() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            clearErrors()
        }

        let regResult = await apiService.registerUser(email: regEmail, password: regPassword, username: regUsername, referralUuid: referralCode)

        switch regResult {
            case .success(let registeredId):
                let verifyResult = await apiService.verifyRegistration(userID: registeredId)

                if case .failure(let apiError) = verifyResult {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        regError = apiError.userFriendlyMessage
                    }
                }

                showRegistrationSuccessCover = true
                registrationSuccessEmail = regEmail
                registrationSuccessPassword = regPassword
                navigationStack.removeAll()
                clearAllFields()
            case .failure(let apiError):
                withAnimation(.easeInOut(duration: 0.2)) {
                    regError = apiError.userFriendlyMessage
                }
        }
    }

    func successCoverContinueButtonTapped() async {
        do {
            try await authManager.login(email: registrationSuccessEmail, password: registrationSuccessPassword)
        } catch {
            withAnimation(.easeInOut(duration: 0.2)) {
                loginError = error.userFriendlyMessage
            }
        }
        showRegistrationSuccessCover = false
        registrationSuccessEmail = ""
        registrationSuccessPassword = ""
    }

    func alreadyRegisteredButtonTapped() {
        navigationStack.removeAll()
        clearAllFields()
    }
}

// MARK: - Password reset

extension AuthorizationViewModel {
    func sendResetPasswordEmailButtonTapped() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            clearErrors()
        }

        let result = await apiService.requestPasswordReset(email: forgotPasswordEmail)

        switch result {
            case .success():
                moveToForgotPasswordCodeScreen()
            case .failure(let apiError):
                withAnimation(.easeInOut(duration: 0.2)) {
                    forgotPasswordErrorEmail = apiError.userFriendlyMessage
                }
        }
    }

    func resendPasswordResetEmailButtonTapped() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            clearErrors()
        }
        
        let result = await apiService.requestPasswordReset(email: forgotPasswordEmail)
        
        switch result {
            case .success():
                print("success")
            case .failure(let apiError):
                withAnimation(.easeInOut(duration: 0.2)) {
                    forgotPasswordErrorResendEmail = apiError.userFriendlyMessage
                }
        }
    }

    func verifyResetPasswordCodeButtonTapped() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            clearErrors()
        }

        let result = await apiService.verifyResetPasswordCode(code: forgotPasswordCode)

        switch result {
            case .success():
                moveToForgotPasswordNewPassScreen()
            case .failure(let apiError):
                withAnimation(.easeInOut(duration: 0.2)) {
                    forgotPasswordErrorBadCode = apiError.userFriendlyMessage
                }
        }
    }

    func evaluateForgotPasswordStrength() {
        if forgotPasswordNewPass.isEmpty {
            forgotPasswordStrength = nil
        } else {
            forgotPasswordStrength = PasswordPolicy.evaluate(regPassword)
        }
    }
}
