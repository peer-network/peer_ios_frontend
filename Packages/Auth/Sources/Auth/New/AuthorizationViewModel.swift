//
//  AuthorizationViewModel.swift
//  Auth
//
//  Created by Artem Vasin on 19.06.25.
//

import SwiftUI
import Models

@MainActor
final class AuthorizationViewModel: ObservableObject {
    unowned var apiService: APIService!

    enum FormType {
        case login
        case referralCode
        case noReferralCode
        case register
        case forgotPasswordEmail
        case forgotPasswordCode
        case forgotPasswordNewPass
    }

    @Published private var navigationStack: [FormType] = [.login]

    // MARK: Login properties
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var loginError = ""

    // MARK: Referral code properties
    @Published var referralCode = ""

    // MARK: Register properties
    @Published var regEmail = ""
    @Published var regUsername = ""
    @Published var regPassword = ""
    @Published var regPasswordRepeat = ""
    @Published private(set) var regPasswordStrength: PasswordStrength = .empty
    @Published var showAgeConfirmationPopup = false
    @Published var showAgeNotEnoughPopup = false

    // MARK: Register properties
    @Published var forgotPasswordEmail = ""
    @Published var forgotPasswordCode = ""
    @Published var forgotPasswordNewPass = ""
    @Published var forgotPasswordRepeatPass = ""
    @Published private(set) var forgotPasswordStrength: PasswordStrength = .empty

    var formType: FormType {
        navigationStack.last ?? .login
    }

    var showBackButton: Bool {
        navigationStack.count > 1
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
        guard navigationStack.count > 1 else { return }
        navigationStack.removeLast()
    }
}

// MARK: - Registration

extension AuthorizationViewModel {
    func evaluateRegisterPasswordStrength() {
        if regPassword.isEmpty {
            regPasswordStrength = .empty
        } else {
            regPasswordStrength = PasswordStrength.evaluatePasswordStrength(regPassword)
        }
    }

    func registerButtonTapped() {
        showAgeConfirmationPopup = true
    }

    func underAgeTapped() {
        showAgeConfirmationPopup = false
        showAgeNotEnoughPopup = true
    }

    func dismissAgeConfirmationTapped() {
        showAgeNotEnoughPopup = false
    }
}

// MARK: - Password reset

extension AuthorizationViewModel {
    func evaluateForgotPasswordStrength() {
        if forgotPasswordNewPass.isEmpty {
            forgotPasswordStrength = .empty
        } else {
            forgotPasswordStrength = PasswordStrength.evaluatePasswordStrength(regPassword)
        }
    }
}
