//
//  AppState.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Combine

@MainActor
public class AppState: ObservableObject {
    @Published public var isLoading = true
    @Published public var error: Error?

    private let configService: ConfigurationServiceProtocol

    public init(configService: ConfigurationServiceProtocol = ConfigurationService()) {
        self.configService = configService
    }

    public func initializeApp() async {
        isLoading = true
        error = nil

        do {
            try await configService.loadAllConfigurations()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public var isUsingCachedData: Bool {
        return configService.isUsingCachedData
    }

    public func getConstants() -> ConstantsConfig? {
        return configService.getConstants()
    }
}
