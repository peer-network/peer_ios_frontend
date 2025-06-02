//
//  PasswordStrength.swift
//  Auth
//
//  Created by Artem Vasin on 02.06.25.
//

import Foundation

enum PasswordStrength: String {
    case empty = ""
    case tooWeak = "Too weak!"
    case notStrongEnough = "Not strong enough!"
    case good = "Good!"
    case excellent = "Excellent!"

    static func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
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
