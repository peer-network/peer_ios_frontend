//
//  VersionHistoryItem.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

import Foundation

public struct VersionHistoryItem: Identifiable, Decodable {
    public let id = UUID()
    let version: String
    let releaseNotes: [String]

    enum CodingKeys: String, CodingKey {
        case version
        case releaseNotes
    }
}
