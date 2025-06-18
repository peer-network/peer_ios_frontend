//
//  CachedConfig.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

struct CachedConfig<T: Codable>: Codable {
    let data: T
    let lastUpdated: Date
    let hash: String
}
