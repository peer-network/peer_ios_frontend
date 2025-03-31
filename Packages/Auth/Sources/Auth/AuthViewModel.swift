//
//  AuthViewModel.swift
//  Auth
//
//  Created by Артем Васин on 27.01.25.
//

import SwiftUI
import Environment
import Networking
import GQLOperationsGuest

// TODO: if there is error in validation of any field, then login/register button is disabled

@MainActor
final class AuthViewModel: ObservableObject {
    enum FormType {
        case login
        case register
    }

    @Published var formType: FormType = .login
    @Published var loading = false

    // MARK: - Login Properties
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var loginError = ""

    // MARK: - Register Properties
    @Published var regEmail: String = ""
    @Published var regPassword: String = "" {
        didSet {
            if regPassword.isEmpty {
                withAnimation {
                    passwordStrength = .empty
                }
            } else {
                withAnimation {
                    passwordStrength = evaluatePasswordStrength(regPassword)
                }
            }
        }
    }
    @Published var regUsername = ""
    @Published var regError = ""

    @Published private(set) var passwordStrength: PasswordStrength = .empty

    weak var authManager: AuthManager?

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func login() async {
        // input validation

        resetErrors()
        loading = true

        defer {
            loading = false
        }

        do {
            try await authManager?.login(email: loginEmail, password: loginPassword)
        } catch {
            withAnimation {
                loginError = "Something went wrong. Please, try again"
            }
        }
    }

    func register() async -> Bool {
        // input validation

        resetErrors()
        loading = true

        defer {
            loading = false
        }

        do {
            let result = try await GQLClient.shared.mutate(mutation: RegisterMutation(email: regEmail, password: regPassword, username: regUsername))

            guard result.register.status == "success" else {
                throw GQLError.missingData
            }

            let result2 = try await GQLClient.shared.mutate(mutation: VerificationMutation(userid: result.register.userid ?? ""))

            regEmail = ""
            regUsername = ""
            regPassword = ""

            return true
        } catch {
            withAnimation {
                regError = "Something went wrong. Please, try again"
            }
            return false
        }
    }

    private func resetErrors() {
        withAnimation {
            loginError = ""
            regError = ""
        }
    }

    deinit {
        print("AuthVM deinit 😎")
    }
}

// MARK: - Password validation

extension AuthViewModel {
    enum PasswordStrength: String {
        case empty = ""
        case tooWeak = "Too weak!"
        case notStrongEnough = "Not strong enough!"
        case good = "Good!"
        case excellent = "Excellent!"
    }

    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        // At minimum, a password must be:
        // 1) >= 8 characters
        // 2) contain at least one uppercase letter
        // 3) contain at least one lowercase letter
        // 4) contain at least one digit

        // Check each requirement
        let lengthRequirement = password.count >= 8
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil

        // Count how many are satisfied
        var score = 0
        score += lengthRequirement ? 1 : 0
        score += hasUppercase      ? 1 : 0
        score += hasLowercase      ? 1 : 0
        score += hasDigit          ? 1 : 0

        // Additional requirement to qualify as "excellent"
        // e.g., length ≥ 12 or has a special character, etc.
        let hasSpecialCharacter = password.rangeOfCharacter(
            from: CharacterSet.punctuationCharacters.union(.symbols)
        ) != nil
        let lengthBonus = password.count >= 12

        let meetsExcellentBonus = hasSpecialCharacter || lengthBonus

        // Decide on final rating:
        switch score {
            case 0, 1:
                return .tooWeak
            case 2:
                return .notStrongEnough
            case 3:
                // 3 means one of the four core checks is missing
                // so still "notStrongEnough" if it doesn't meet all 4
                return .notStrongEnough
            case 4:
                // All minimum requirements are met
                return meetsExcellentBonus ? .excellent : .good
            default:
                // Should never hit here, but as a fallback:
                return .tooWeak
        }
    }
}

// MARK: - Email and Username validation

extension AuthViewModel {
    func isValidUsername(_ username: String) -> Bool {
        let pattern = #"^[A-Za-z0-9_]{3,23}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: username)
    }

    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9_.±]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
}
