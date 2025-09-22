//
//  CachedConfig.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

struct CachedConfig: Codable {
    let hash: String
    let lastUpdated: Date
    let payload: Data
}
