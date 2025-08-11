//
//  ConfigurationServiceProtocol.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

public protocol ConfigurationServiceProtocol {
    // Primary methods
    func loadAllConfigurations() async throws
    func getConstants() -> ConstantsConfig?

    // Cache methods
    func loadCachedConstants() throws -> ConstantsConfig?
    var isUsingCachedData: Bool { get }

    // For testing/mocking
    func forceUseCachedData()
}
