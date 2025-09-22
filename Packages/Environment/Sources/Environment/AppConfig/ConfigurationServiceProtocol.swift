//
//  ConfigurationServiceProtocol.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

public protocol ConfigurationServiceProtocol {
    func loadAllConfigurations() async throws
    func getConstants() -> ConstantsConfig?
    func loadCachedConstants() -> ConstantsConfig?
    var isUsingCachedData: Bool { get }

    /// For testing/mocking
    func forceUseCachedData()
}
