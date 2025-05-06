//
//  ErrorCodes.swift
//  Networking
//
//  Created by Artem Vasin on 06.05.25.
//

import Foundation

struct ErrorCodeResponse: Codable {
    let name: String
    let createdAt: TimeInterval
    let data: [String: ErrorCode]
}

struct ErrorCode: Codable {
    let comment: String
    let userFriendlyComment: String
}
