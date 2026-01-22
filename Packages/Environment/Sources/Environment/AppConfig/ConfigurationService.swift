//
//  ConfigurationService.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

public class ConfigurationService: ConfigurationServiceProtocol {
    private let configURL: URL
    private let cacheManager: ConfigCacheManager
    private var constantsConfig: ConstantsConfig?
    public private(set) var isUsingCachedData = false

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init(configURL: URL, cacheManager: ConfigCacheManager) {
        self.configURL = configURL
        self.cacheManager = cacheManager
        decoder.dateDecodingStrategy = .secondsSince1970
        encoder.dateEncodingStrategy = .secondsSince1970
    }

    public convenience init() {
        let cacheManager = try! FileConfigCacheManager()
        self.init(
            configURL: URL(string: "https://media.peerapp.eu/assets/config.json")!,
            cacheManager: cacheManager
        )
    }

    public func loadAllConfigurations() async throws {
        isUsingCachedData = false

        let appConfig: AppConfig
        do {
            appConfig = try await fetchJSON(AppConfig.self, from: configURL)
        } catch {
            if let cached = loadCachedConstants() {
                constantsConfig = cached
                isUsingCachedData = true
                return
            }
            throw error
        }

        constantsConfig = try await fetchAndCache(
            key: "constants",
            expectedHash: appConfig.data.constants.hash,
            urlString: appConfig.data.constants.url,
            as: ConstantsConfig.self
        )

        // TODO: repeat for response-codes and endpoints using their models.
    }

    public func getConstants() -> ConstantsConfig? { constantsConfig }

    public func loadCachedConstants() -> ConstantsConfig? {
        cacheManager.load(forKey: "constants", expectedHash: nil, as: ConstantsConfig.self, decoder: decoder)
    }

    public func forceUseCachedData() { isUsingCachedData = true }

    // MARK: - Helpers

    private func fetchAndCache<T: Decodable>(
        key: String,
        expectedHash: String,
        urlString: String,
        as type: T.Type
    ) async throws -> T {
        if let cached: T = cacheManager.load(forKey: key, expectedHash: expectedHash, as: T.self, decoder: decoder) {
            isUsingCachedData = true
            return cached
        }

        // Otherwise fetch fresh and cache raw bytes.
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (bytes, _) = try await urlSessionData(from: url)

        // Try decoding; if this fails, we want that error to surface (schema really incompatible).
        let decoded = try decoder.decode(T.self, from: bytes)
        try cacheManager.saveRaw(bytes, forKey: key, hash: expectedHash)
        isUsingCachedData = false
        return decoded
    }

    private func fetchJSON<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, _) = try await urlSessionData(from: url)
        return try decoder.decode(T.self, from: data)
    }

    private func urlSessionData(from url: URL) async throws -> (Data, URLResponse) {
        var req = URLRequest(url: url)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.timeoutInterval = 20
        return try await URLSession.shared.data(for: req)
    }
}
