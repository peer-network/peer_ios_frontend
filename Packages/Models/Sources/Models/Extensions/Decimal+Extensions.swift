//
//  Decimal+Extensions.swift
//  Models
//
//  Created by Artem Vasin on 15.01.26.
//

import Foundation

extension Decimal {
    /// Parses decimals like "-0.0000000100" reliably (dot as decimal separator).
    init?(graphqlNumericString: String?) {
        guard var s = graphqlNumericString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !s.isEmpty
        else { return nil }

        // Ensure decimal separator is "." regardless of device locale
        s = s.replacingOccurrences(of: ",", with: ".")

        // Use NSDecimalNumber with a fixed locale to avoid "de_DE" parsing issues.
        let locale = Locale(identifier: "en_US_POSIX")
        let number = NSDecimalNumber(string: s, locale: locale)

        if number == .notANumber { return nil }
        self = number.decimalValue
    }
}
