//
//  PasswordStrength.swift
//  Auth
//
//  Created by Artem Vasin on 02.06.25.
//

import Foundation

enum PasswordStrength: String {
    case empty = ""
    case veryWeak = "Very weak"
    case weak = "Weak"
    case notStrongEnough = "Needs improvement"
    case good = "Strong"
    case strong = "Excellent"
}

enum PasswordRequirement: CaseIterable {
    case minLength, lowercase, uppercase, number

    var phrase: String {
        switch self {
        case .minLength: return "8 characters"
        case .lowercase: return "1 lowercase"
        case .uppercase: return "1 uppercase"
        case .number:    return "1 number"
        }
    }
}

struct PasswordEvaluation {
    let strength: PasswordStrength
    let unmetRequirements: [PasswordRequirement]
    let meetsExcellentBonus: Bool
}

enum PasswordPolicy {
    static func evaluate(_ password: String) -> PasswordEvaluation {
        // Core checks
        let lengthRequirement = password.count >= 8
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil

        // Unmet in the order they should appear in the hint
        var unmet: [PasswordRequirement] = []
        if !lengthRequirement { unmet.append(.minLength) }
        if !hasLowercase     { unmet.append(.lowercase) }
        if !hasUppercase     { unmet.append(.uppercase) }
        if !hasDigit         { unmet.append(.number) }

        // Score for strength
        var score = 0
        score += lengthRequirement ? 1 : 0
        score += hasUppercase      ? 1 : 0
        score += hasLowercase      ? 1 : 0
        score += hasDigit          ? 1 : 0

        // Bonus for "Excellent"
        let hasSpecialCharacter = password.rangeOfCharacter(
            from: CharacterSet.punctuationCharacters.union(.symbols)
        ) != nil
        let lengthBonus = password.count >= 12
        let meetsExcellentBonus = hasSpecialCharacter || lengthBonus

        let strength: PasswordStrength
        switch score {
        case 0, 1:
            strength = .veryWeak
        case 2:
            strength = .weak
        case 3:
            strength = .notStrongEnough
        case 4:
            strength = meetsExcellentBonus ? .strong : .good
        default:
            strength = .veryWeak
        }

        // Empty convenience: if they haven't typed anything, surface nothing as strength label
        let finalStrength: PasswordStrength = password.isEmpty ? .empty : strength

        return PasswordEvaluation(
            strength: finalStrength,
            unmetRequirements: unmet,
            meetsExcellentBonus: meetsExcellentBonus
        )
    }
}
