//
//  Bundle+Extensions.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 13.03.25.
//

import Foundation

extension Bundle {
    static var appVersionBundle: String {
        guard
            let info = Bundle.main.infoDictionary,
            let version = info["CFBundleShortVersionString"] as? String
        else {
            return ""
        }

        return version
    }

    static var appBuildBundle: String {
        guard
            let info = Bundle.main.infoDictionary,
            let version = info["CFBundleVersion"] as? String
        else {
            return ""
        }

        return version
    }
}
