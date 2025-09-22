//
//  ConfigCacheManager.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

public protocol ConfigCacheManager {
    func saveRaw(_ data: Data, forKey key: String, hash: String) throws
    func loadRaw(forKey key: String, expectedHash: String?) throws -> Data?
    func clearCache()
}

extension ConfigCacheManager {
    /// Convenience generic decode that never throws on schema issues.
    public func load<T: Decodable>(
        forKey key: String,
        expectedHash: String?,
        as type: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T? {
        guard let raw = try? loadRaw(forKey: key, expectedHash: expectedHash) else { return nil }
        return try? decoder.decode(T.self, from: raw) // if this fails, treat as cache miss
    }
}
