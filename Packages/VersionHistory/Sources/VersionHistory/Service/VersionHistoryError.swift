//
//  VersionHistoryError.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

import Foundation

public enum VersionHistoryError: Error {
    case fileNotFound
    case decodingError
    case unknown
}

extension VersionHistoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .fileNotFound:
                return NSLocalizedString("Failed to find version history data.", comment: "Failed to find a file with version history data")
            case .decodingError:
                return NSLocalizedString("Failed to decode version history data.", comment: "Failed to decode version history data")
            case .unknown:
                return nil
        }
    }
}
