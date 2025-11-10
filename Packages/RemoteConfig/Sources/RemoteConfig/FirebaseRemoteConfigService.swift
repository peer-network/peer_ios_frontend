//
//  FirebaseRemoteConfigService.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

import FirebaseRemoteConfig
import FirebaseCore

public final class FirebaseRemoteConfigService: RemoteConfigProtocol {
    private let remoteConfig: RemoteConfig
    private var configUpdateListener: ConfigUpdateListenerRegistration?

    public init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        setupConfig()
        setDefaults()
    }

    private func setupConfig() {
        let settings = RemoteConfigSettings()
#if DEBUG || STAGING
        // DO NOT DECREASE IT UNTIL ACTUALLY NEEDED. THE FIREBASE QUOTA FOR CONFIG FETCHES IS REALLY LIMITED
        settings.minimumFetchInterval = 43200 // Frequent updates for debugging (10 sec, for example)
#else
        settings.minimumFetchInterval = 43200 // 12 hours in production
#endif
        remoteConfig.configSettings = settings
    }

    private func setDefaults() {
        let defaults = RemoteConfigValueKey.allCases.reduce(into: [String: NSObject]()) { result, key in
            if let value = key.defaultValue as? NSObject {
                result[key.name] = value
            }
        }
        remoteConfig.setDefaults(defaults)
    }

    public func fetchConfig() async throws {
        do {
            try await remoteConfig.fetch()
        } catch {
            throw RemoteConfigError.fetchError(error)
        }
    }

    public func activateConfig() async throws -> Bool {
        do {
            return try await remoteConfig.activate()
        } catch {
            throw RemoteConfigError.activationError(error)
        }
    }

    public func addConfigUpdateListener(handler: @escaping (Result<Bool, any Error>) -> Void) {
        configUpdateListener = remoteConfig.addOnConfigUpdateListener { [weak self] configUpdate, error in
            if let error {
                handler(.failure(RemoteConfigError.configUpdateError(error)))
                return
            }

            guard let self else { return }

            Task {
                do {
                    let changed = try await self.remoteConfig.activate()
                    handler(.success(changed))
                } catch {
                    handler(.failure(RemoteConfigError.activationError(error)))
                }
            }
        }
    }

    public func bool(for key: RemoteConfigValueKey) -> Bool {
        return remoteConfig[key.name].boolValue
    }

    public func string(for key: RemoteConfigValueKey) -> String {
        return remoteConfig[key.name].stringValue
    }

    public func double(for key: RemoteConfigValueKey) -> Double {
        return remoteConfig[key.name].numberValue.doubleValue
    }

    public func int(for key: RemoteConfigValueKey) -> Int {
        return remoteConfig[key.name].numberValue.intValue
    }

    deinit {
        configUpdateListener?.remove()
    }
}

extension FirebaseRemoteConfigService {
    public func decodedObject<T: Decodable>(for key: RemoteConfigValueKey) throws -> T {
        let jsonString = remoteConfig[key.name].stringValue

        guard let data = jsonString.data(using: .utf8) else {
            throw RemoteConfigError.keyNotFound(key.name)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw RemoteConfigError.typeMismatch("Failed to decode \(T.self) from key \(key.name): \(error)")
        }
    }
}
