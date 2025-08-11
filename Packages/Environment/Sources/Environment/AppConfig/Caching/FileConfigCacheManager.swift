//
//  FileConfigCacheManager.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

class FileConfigCacheManager: ConfigCacheManager {
    private let fileManager: FileManager
    private let cacheDirectory: URL

    init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager
        let documentsDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        self.cacheDirectory = documentsDirectory.appendingPathComponent("ConfigCache")

        try createCacheDirectoryIfNeeded()
    }

    private func createCacheDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true
            )
        }
    }

    private func fileURL(forKey key: String) -> URL {
        return cacheDirectory.appendingPathComponent("\(key).json")
    }

    func save<T: Codable>(_ config: T, forKey key: String, hash: String) throws {
        let cached = CachedConfig(data: config, lastUpdated: Date(), hash: hash)
        let data = try JSONEncoder().encode(cached)
        try data.write(to: fileURL(forKey: key))
    }

    func load<T: Codable>(forKey key: String, expectedHash: String?) throws -> T? {
        let fileURL = fileURL(forKey: key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        let data = try Data(contentsOf: fileURL)
        let cached = try JSONDecoder().decode(CachedConfig<T>.self, from: data)

        if let expectedHash = expectedHash, cached.hash != expectedHash {
            return nil
        }

        return cached.data
    }

    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? createCacheDirectoryIfNeeded()
    }
}
