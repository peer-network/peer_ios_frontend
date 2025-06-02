//
//  MockRemoteConfigService.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

import Foundation

// let mockService = MockRemoteConfigService()
// mockService.setMockValue(true, for: .isForceUpdateRequired)
// let viewModel = RemoteConfigViewModel(configService: mockService)

public final class MockRemoteConfigService: RemoteConfigProtocol {
    private var mockValues: [RemoteConfigValueKey: Any] = [:]
    private var fetchShouldFail = false
    private var activateShouldFail = false

    public init() {
        // Set default mock values
        RemoteConfigValueKey.allCases.forEach { key in
            mockValues[key] = key.defaultValue
        }
    }
    public func setMockValue(_ value: Any, for key: RemoteConfigValueKey) {
        mockValues[key] = value
    }

    public func setFetchShouldFail(_ shouldFail: Bool) {
        fetchShouldFail = shouldFail
    }

    public func setActivateShouldFail(_ shouldFail: Bool) {
        activateShouldFail = shouldFail
    }

    public func fetchConfig() async throws {
        if fetchShouldFail {
            throw RemoteConfigError.fetchError(NSError(domain: "MockError", code: -1))
        }
        // Simulate network delay
        try await Task.sleep(for: .seconds(5))
    }

    public func activateConfig() async throws -> Bool {
        if activateShouldFail {
            throw RemoteConfigError.activationError(NSError(domain: "MockError", code: -1))
        }
        return true
    }

    public func addConfigUpdateListener(handler: @escaping (Result<Bool, Error>) -> Void) {
        // No-op in mock
    }

    public func string(for key: RemoteConfigValueKey) -> String {
        mockValues[key] as? String ?? ""
    }

    public func bool(for key: RemoteConfigValueKey) -> Bool {
        mockValues[key] as? Bool ?? false
    }

    public func int(for key: RemoteConfigValueKey) -> Int {
        mockValues[key] as? Int ?? 0
    }

    public func double(for key: RemoteConfigValueKey) -> Double {
        mockValues[key] as? Double ?? 0.0
    }
}

extension MockRemoteConfigService {
    public func decodedObject<T: Decodable>(for key: RemoteConfigValueKey) throws -> T {
        guard let value = mockValues[key] as? T else {
            throw RemoteConfigError.typeMismatch("Mock value for \(key.name) is not of type \(T.self)")
        }
        return value
    }
}
