//
//  AuthViewModel.swift
//  Auth
//
//  Created by Артем Васин on 27.01.25.
//

import SwiftUI
import Environment
import Models

// TODO: if there is error in validation of any field, then login/register button is disabled

@MainActor
public final class AuthViewModel: ObservableObject {
    enum FormType {
        case login
        case register
        case forgotPassword
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
                    passwordStrength = PasswordStrength.evaluatePasswordStrength(regPassword)
                }
            }
        }
    }
    @Published var regUsername = ""
    @Published var regReferralCode = ""
    @Published var regError = ""

    @Published private(set) var passwordStrength: PasswordStrength = .empty

    //why weak var?
    weak var authManager: AuthManager?
    public unowned var apiService: APIService!

    public init(authManager: AuthManager) {
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
                loginError = error.userFriendlyMessage
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
            let regResult = await apiService.registerUser(email: regEmail, password: regPassword, username: regUsername, referralUuid: regReferralCode)

            switch regResult {
                case .success(let registeredId):
                    let verifyResult = await apiService.verifyRegistration(userID: registeredId)

                    if case .failure(let apiError) = verifyResult {
                        throw apiError
                    }
                case .failure(let apiError):
                    throw apiError
            }

            regEmail = ""
            regUsername = ""
            regPassword = ""
            regReferralCode = ""

            return true
        } catch let apiError as APIError {
            withAnimation {
                regError = apiError.userFriendlyMessage
            }
            return false
        } catch {
            withAnimation {
                regError = "Something went wrong. Please, try again"
            }
            return false
        }
    }

    func setReferralCode(_ code: String) {
        // TODO: Validation checks here
        regReferralCode = code
        formType = .register
    }

    private func resetErrors() {
        withAnimation {
            loginError = ""
            regError = ""
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
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
}
