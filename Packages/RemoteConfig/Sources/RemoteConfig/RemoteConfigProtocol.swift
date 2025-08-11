//
//  RemoteConfigProtocol.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

public protocol RemoteConfigProtocol {
    func fetchConfig() async throws
    @discardableResult
    func activateConfig() async throws -> Bool
    func addConfigUpdateListener(handler: @escaping (Result<Bool, Error>) -> Void)

    func string(for key: RemoteConfigValueKey) -> String
    func bool(for key: RemoteConfigValueKey) -> Bool
    func int(for key: RemoteConfigValueKey) -> Int
    func double(for key: RemoteConfigValueKey) -> Double
    func decodedObject<T: Decodable>(for key: RemoteConfigValueKey) throws -> T
}
