//
//  Error+Extensions.swift
//  Models
//
//  Created by Artem Vasin on 07.05.25.
//

public extension Error {
    var userFriendlyDescription: String {
        if let apiError = self as? APIError {
            return apiError.userFriendlyMessage
        }
        return localizedDescription
    }
}

