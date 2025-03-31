//
//  RemoteConfigService.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 12.03.25.
//

import FirebaseRemoteConfig
import Foundation

public final class RemoteConfigService {
    public static let shared = RemoteConfigService()

    public let remoteConfig = RemoteConfig.remoteConfig()

    @RemoteConfigProperty(
        key: ConfigKeys.FORCE_UPDATE_CURRENT_VERSION.rawValue,
        fallback: "1.0.0"
    )
    private var configCurrentVersion

    @RemoteConfigProperty(
        key: ConfigKeys.IS_FORCE_UPDATE_REQUIRED.rawValue,
        fallback: false
    )
    private var configIsForceUpdateRequired

    @RemoteConfigProperty(
        key: ConfigKeys.FORCE_UPDATE_STORE_URL.rawValue,
        fallback: "https://testflight.apple.com/join/xcCR5A67"
    )
    private var configStoreUrl

    public var storeUrl: URL? { URL(string: configStoreUrl) }

    private var getCurrentBundleVersion: String {
        "\(Bundle.appVersionBundle)\(Bundle.appBuildBundle)"
    }

    private init() {
        setupRemoteConfigSettings()
        fetchAndActivate()
    }

    private func setupRemoteConfigSettings() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }

    public func fetchAndActivate() {
        Task {
            do {
                try await remoteConfig.fetchAndActivate()
            } catch {
                print("Failed to fetch remote config: \(error)")
            }
        }
    }

    public func checkIfUpdateRequired() -> Bool {
        guard configIsForceUpdateRequired else { return false }

        guard storeUrl != nil else { return false }

        guard !getCurrentBundleVersion.isEmpty else { return false }

        if getCurrentBundleVersion < configCurrentVersion {
            return true
        }

        return false
    }
}
