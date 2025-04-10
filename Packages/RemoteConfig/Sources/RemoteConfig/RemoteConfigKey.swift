//
//  RemoteConfigKey.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

public enum RemoteConfigValueKey: CaseIterable {
    case forceUpdateCurrentVersion
    case forceUpdateStoreURL
    case isForceUpdateRequired

    public var name: String {
        switch self {
            case .forceUpdateCurrentVersion:
                return "force_update_current_version"
            case .forceUpdateStoreURL:
                return "force_update_store_url"
            case .isForceUpdateRequired:
                return "is_force_update_required"
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
        }
    }
}
