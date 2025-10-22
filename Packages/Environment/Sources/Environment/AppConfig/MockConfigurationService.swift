//
//  MockConfigurationService.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

class MockConfigurationService: ConfigurationServiceProtocol {
    // Inputs to simulate scenarios
    var simulateNetworkFailure = false
    var simulateCacheHasGoodHash = false
    var simulateCacheCorrupt = false
    
    // Output state
    private(set) var constants: ConstantsConfig?
    private(set) var usingCache = false
    
    var isUsingCachedData: Bool { usingCache }
    
    func loadAllConfigurations() async throws {
        // Simulate bootstrap fetch
        if simulateNetworkFailure && !simulateCacheHasGoodHash {
            // No network and no valid cache → throw
            if loadCachedConstants() == nil { throw URLError(.cannotConnectToHost) }
            usingCache = true
            return
        }
        
        // Pretend we fetched the bootstrap AppConfig successfully:
        let remoteHash = "remote-hash-123"
        let remoteURL = "https://example.com/constants.json"
        
        // Cache path
        if simulateCacheHasGoodHash {
            if simulateCacheCorrupt {
                // Corrupt cache → should refetch and overwrite
                // We'll just ignore and proceed to "network fetch"
            } else {
                usingCache = true
                constants = Self.sampleConstants(hash: remoteHash)
                return
            }
        }
        
        // Network fetch result (unless network is down)
        if simulateNetworkFailure {
            // No network; if we still got here, it's because cache hash mismatched or was corrupt
            if let cached = loadCachedConstants() { constants = cached; usingCache = true; return }
            throw URLError(.cannotConnectToHost)
        }
        
        // Success path: fetch and decode, then cache
        // (We don't implement actual caching here; just pretend network gives us this:)
        constants = Self.sampleConstants(hash: remoteHash)
        usingCache = false
    }
    
    func getConstants() -> ConstantsConfig? { constants }
    
    func loadCachedConstants() -> ConstantsConfig? {
        // If you want, return an old model here to test consumers vs. schema changes.
        nil
    }
    
    func forceUseCachedData() { usingCache = true }
    
    private static func sampleConstants(hash: String) -> ConstantsConfig {
        ConstantsConfig(
            createdAt: Date().timeIntervalSince1970,
            hash: hash,
            name: "constants",
            data: .init(
                post: .init(
                    title: .init(minLength: 2, maxLength: 63),
                    mediaDescription: .init(minLength: 3, maxLength: 500)
                ),
                comment: .init(content: .init(minLength: 2, maxLength: 200)),
                user: .init(username: .init(minLength: 3, maxLength: 23, pattern: "^[a-zA-Z0-9_-]+$"), password: .init(minLength: 8, maxLength: 128, pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$"), biography: .init(minLength: 3, maxLength: 5000)),
                dailyFree: .init(dailyFreeActions: .init(post: 1, like: 3, comment: 4, dislike: 0)),
                tokenomics: .init(
                    actionTokenPrices: .init(post: 20, like: 3, comment: 3, dislike: 1),
                    actionGemsReturn: .init(view: 0.25, like: 5, comment: -3, dislike: 2)
                ),
                minting: .init(dailyNumberTokens: 5000)
            )
        )
    }
}
