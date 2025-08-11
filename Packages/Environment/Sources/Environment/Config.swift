//
//  Config.swift
//  Environment
//
//  Created by Артем Васин on 19.12.24.
//

import UIKit

public enum Config {
    public static let appGroup = "group.eu.peernetwork.PeerApp"

    public static let pushesRegistrationURL: String = "https://peernetwork.eu/graphql"
}

public extension Notification.Name {
  static let scrollToTop = Notification.Name("ScrollToTopNotification")
}
