//
//  FileConfigCacheManager.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

class FileConfigCacheManager: ConfigCacheManager {
    private let fm: FileManager
    private let dir: URL

    init(fileManager: FileManager = .default) throws {
        self.fm = fileManager
        let base = try fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.dir = base.appendingPathComponent("ConfigCache", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    private func url(forKey key: String) -> URL {
        dir.appendingPathComponent("\(key).json")
    }

    func saveRaw(_ data: Data, forKey key: String, hash: String) throws {
        let env = CachedConfig(hash: hash, lastUpdated: Date(), payload: data)
        let bytes = try JSONEncoder().encode(env)
        try bytes.write(to: url(forKey: key), options: .atomic)
    }

    func loadRaw(forKey key: String, expectedHash: String?) throws -> Data? {
        let f = url(forKey: key)
        guard fm.fileExists(atPath: f.path) else { return nil }
        do {
            let bytes = try Data(contentsOf: f)
            let env = try JSONDecoder().decode(CachedConfig.self, from: bytes)
            if let expectedHash, env.hash != expectedHash { return nil }
            return env.payload
        } catch {
            // Corrupt/legacy cache: drop it and return nil
            try? fm.removeItem(at: f)
            return nil
        }
    }

    func clearCache() {
        try? fm.removeItem(at: dir)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }
}
