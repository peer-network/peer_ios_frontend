//
//  AppConfig.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

struct AppConfig: Codable {
    let createdAt: TimeInterval
    let name: String
    let data: ConfigData

    struct ConfigData: Codable {
        let constants: ConfigItem
        let responseCodes: ConfigItem
        let endpoints: ConfigItem

        enum CodingKeys: String, CodingKey {
            case constants
            case responseCodes = "response-codes"
            case endpoints
        }
    }
}

struct ConfigItem: Codable {
    let createdAt: TimeInterval
    let hash: String
    let url: String
}
