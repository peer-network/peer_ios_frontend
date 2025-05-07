//
//  ErrorCodeManager.swift
//  Networking
//
//  Created by Artem Vasin on 06.05.25.
//

import Foundation

public class ErrorCodeManager {
    public static let shared = ErrorCodeManager()
    private var errorCodes: [String: ErrorCode] = [:]

    private init() {}

    public func loadErrorCodes() async throws {
        let (data, _) = try await URLSession.shared.data(from: Constants.errorCodesURL)
        let response = try JSONDecoder().decode(ErrorCodeResponse.self, from: data)
        self.errorCodes = response.data
    }

    public func getUserFriendlyMessage(for code: String) -> String {
        return errorCodes[code]?.userFriendlyComment ?? "Something went wrong, hint: \(code)"
    }

    public func getDeveloperMessage(for code: String) -> String {
        return errorCodes[code]?.comment ?? "Unknown error code: \(code)"
    }
}
