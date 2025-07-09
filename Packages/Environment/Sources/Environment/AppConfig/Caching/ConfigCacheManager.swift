//
//  ConfigCacheManager.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

public protocol ConfigCacheManager {
    func save<T: Codable>(_ config: T, forKey key: String, hash: String) throws
    func load<T: Codable>(forKey key: String, expectedHash: String?) throws -> T?
    func clearCache()
}

extension ConfigCacheManager {
    func load<T: Codable>(forKey key: String) throws -> T? {
        return try load(forKey: key, expectedHash: nil)
    }
}
