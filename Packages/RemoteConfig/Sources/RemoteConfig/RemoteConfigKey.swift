//
//  RemoteConfigKey.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

@frozen
public enum RemoteConfigValueKey: CaseIterable {
    case forceUpdateCurrentVersion
    case forceUpdateStoreURL
    case isForceUpdateRequired
    case backendURLs

    public var name: String {
        switch self {
            case .forceUpdateCurrentVersion:
                return "force_update_current_version"
            case .forceUpdateStoreURL:
                return "force_update_store_url"
            case .isForceUpdateRequired:
                return "is_force_update_required"
            case .backendURLs:
                return "ios_backend_urls"
        }
    }

    public var defaultValue: Any {
        switch self {
            case .forceUpdateCurrentVersion:
                return "1.0.0"
            case .forceUpdateStoreURL:
                return "https://testflight.apple.com/join/xcCR5A67"
            case .isForceUpdateRequired:
                return false
            case .backendURLs:
                return BackendURLs.placeholder
        }
    }
}
