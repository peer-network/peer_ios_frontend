//
//  UserDefaults+Extensions.swift
//  PeerApp
//
//  Created by Артем Васин on 14.12.24.
//

import Foundation
import Environment
import Models

extension UserDefaults {
    static let extensions = UserDefaults(suiteName: Config.appGroup)!

    private enum Keys {
        static let badge = "badge"
        static let offensiveContentFilter = "offensiveContentFilter"
        static let username = "username"
    }

    var badge: Int {
        get { UserDefaults.extensions.integer(forKey: Keys.badge) }
        set { UserDefaults.extensions.set(newValue, forKey: Keys.badge) }
    }

    var offensiveContentFilter: OffensiveContentFilter {
        get { UserDefaults.extensions.value(forKey: Keys.offensiveContentFilter) as? OffensiveContentFilter ?? .blocked }
        set { UserDefaults.extensions.set(newValue, forKey: Keys.offensiveContentFilter) }
    }

    var username: String {
        get { UserDefaults.extensions.string(forKey: Keys.username) ?? "" }
        set { UserDefaults.extensions.set(newValue, forKey: Keys.username) }
    }
}
