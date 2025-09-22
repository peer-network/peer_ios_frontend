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
    let data: DataSection

    struct DataSection: Codable {
        let constants: Item
        let responseCodes: Item
        let endpoints: Item

        enum CodingKeys: String, CodingKey {
            case constants
            case responseCodes = "response-codes"
            case endpoints
        }
    }

    struct Item: Codable {
        let createdAt: TimeInterval
        let hash: String
        let url: String
    }
}
