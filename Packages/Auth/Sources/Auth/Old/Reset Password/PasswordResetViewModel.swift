//
//  PasswordResetViewModel.swift
//  Auth
//
//  Created by Artem Vasin on 23.05.25.
//

import SwiftUI
import Models

@MainActor
final class PasswordResetViewModel: ObservableObject {
    public unowned var apiService: APIService!

    @Published var error: String = ""

    @Published var newPassword: String = "" {
        didSet {
            if newPassword.isEmpty {
                withAnimation {
                    passwordStrength = .empty
                }
            } else {
                withAnimation {
//                    passwordStrength = PasswordStrength.evaluatePasswordStrength(newPassword)
                }
            }
        }
    }

    @Published private(set) var passwordStrength: PasswordStrength = .empty

    func requestPasswordReset(email: String) async -> Bool {
        do {
            withAnimation {
                error = ""
            }
            let result = await apiService.requestPasswordReset(email: email)

            switch result {
                case .success():
                    return true
                case .failure(let apiError):
                    throw apiError
            }
        } catch {
            withAnimation {
                self.error = error.userFriendlyDescription
            }
            return false
        }
    }

    func resetPassword(token: String, newPassword: String) async -> Bool {
        do {
            withAnimation {
                error = ""
            }

            let result = await apiService.resetPassword(token: token, newPassword: newPassword)

            switch result {
                case .success():
                    return true
                case .failure(let apiError):
                    throw apiError
            }
        } catch {
            withAnimation {
                self.error = error.userFriendlyDescription
            }
            return false
        }
    }
}

extension PasswordResetViewModel {
    func isValidUsername(_ username: String) -> Bool {
        let pattern = #"^[A-Za-z0-9_]{3,23}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: username)
    }

    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
}
