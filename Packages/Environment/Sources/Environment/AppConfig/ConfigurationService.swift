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

    public init(configURL: URL, cacheManager: ConfigCacheManager) {
        self.configURL = configURL
        self.cacheManager = cacheManager
    }

    public convenience init() {
        let cacheManager = try! FileConfigCacheManager()
        self.init(
            configURL: URL(string: "https://media.getpeer.eu/assets/config.json")!,
            cacheManager: cacheManager
        )
    }

    public func loadAllConfigurations() async throws {
        isUsingCachedData = false

        do {
            var request = URLRequest(url: configURL)
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let (mainConfigData, _) = try await URLSession.shared.data(for: request)
            let mainConfig = try JSONDecoder().decode(AppConfig.self, from: mainConfigData)

            // Load constants
            if let cached: ConstantsConfig = try cacheManager.load(
                forKey: "constants",
                expectedHash: mainConfig.data.constants.hash
            ) {
                constantsConfig = cached
                isUsingCachedData = true
            } else {
                constantsConfig = try await loadConfig(
                    url: mainConfig.data.constants.url,
                    type: ConstantsConfig.self
                )
                try cacheManager.save(
                    constantsConfig!,
                    forKey: "constants",
                    hash: mainConfig.data.constants.hash
                )
            }

            // Repeat for other configs...

        } catch {
            // If network fails but we have cached data, use it
            if constantsConfig == nil, let cached = try? loadCachedConstants() {
                constantsConfig = cached
                isUsingCachedData = true
            } else {
                throw error
            }
        }
    }

    private func loadConfig<T: Codable>(url: String, type: T.Type) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(type, from: data)
    }

    public func loadCachedConstants() throws -> ConstantsConfig? {
        return try cacheManager.load(forKey: "constants")
    }

    public func getConstants() -> ConstantsConfig? {
        return constantsConfig
    }

    public func forceUseCachedData() {
        isUsingCachedData = true
    }
}
