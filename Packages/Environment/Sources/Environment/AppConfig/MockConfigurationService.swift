//
//  MockConfigurationService.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

class MockConfigurationService: ConfigurationServiceProtocol {
    // Configuration storage
    var constantsConfig: ConstantsConfig?

    // Mock control properties
    var shouldThrowError = false
    var shouldReturnStaleCache = false
    var mockIsUsingCachedData = false

    // Protocol requirements
    var isUsingCachedData: Bool {
        return mockIsUsingCachedData
    }

    func loadAllConfigurations() async throws {
        if shouldThrowError {
            throw URLError(.cannotConnectToHost)
        }

        if shouldReturnStaleCache {
            // Return cached data with old hash
            constantsConfig = ConstantsConfig(
                createdAt: Date().timeIntervalSince1970 - 10000,
                hash: "old-hash",
                name: "constants",
                data: ConstantsConfig.ConstantsData(
                    post: ConstantsConfig.PostConstants(
                        title: ConstantsConfig.LengthConstraints(minLength: 2, maxLength: 63),
                        mediaDescription: ConstantsConfig.LengthConstraints(minLength: 3, maxLength: 500)
                    ),
                    comment: ConstantsConfig.CommentConstants(
                        content: ConstantsConfig.LengthConstraints(minLength: 2, maxLength: 200)
                    )
                )
            )
            mockIsUsingCachedData = true
            return
        }

        // Return fresh data
        constantsConfig = ConstantsConfig(
            createdAt: Date().timeIntervalSince1970,
            hash: "mock-hash",
            name: "constants",
            data: ConstantsConfig.ConstantsData(
                post: ConstantsConfig.PostConstants(
                    title: ConstantsConfig.LengthConstraints(minLength: 2, maxLength: 63),
                    mediaDescription: ConstantsConfig.LengthConstraints(minLength: 3, maxLength: 500)
                ),
                comment: ConstantsConfig.CommentConstants(
                    content: ConstantsConfig.LengthConstraints(minLength: 2, maxLength: 200)
                )
            )
        )
        mockIsUsingCachedData = false
    }

    func getConstants() -> ConstantsConfig? {
        return constantsConfig
    }

    func loadCachedConstants() throws -> ConstantsConfig? {
        // For testing cache loading behavior
        return constantsConfig
    }

    func forceUseCachedData() {
        mockIsUsingCachedData = true
    }
}
