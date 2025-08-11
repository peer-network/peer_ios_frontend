//
//  BackendURLs.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 21.05.25.
//

import Foundation

struct BackendURLs: Codable {
    let name: String
    let versions: [AppVersion]

    func urlForCurrentVersion() -> String? {
        let currentVersion = Bundle.appVersionBundle
        return versions.first { $0.appVersion == currentVersion }?.backendURL
    }
}

extension BackendURLs {
    static let placeholder = BackendURLs(
        name: "Placeholder",
        versions: [AppVersion(appVersion: Bundle.appVersionBundle, backendURL: "https://peernetwork.eu")]
    )
}

struct AppVersion: Codable {
    let appVersion: String
    let backendURL: String

    enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case backendURL = "backend_url"
    }
}
