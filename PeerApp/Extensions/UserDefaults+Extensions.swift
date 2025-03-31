//
//  UserDefaults+Extensions.swift
//  PeerApp
//
//  Created by Артем Васин on 14.12.24.
//

import Foundation
import Environment

extension UserDefaults {
    static let extensions = UserDefaults(suiteName: Config.appGroup)!

    private enum Keys {
        static let badge = "badge"
    }

    var badge: Int {
        get { UserDefaults.extensions.integer(forKey: Keys.badge) }
        set { UserDefaults.extensions.set(newValue, forKey: Keys.badge) }
    }
}
