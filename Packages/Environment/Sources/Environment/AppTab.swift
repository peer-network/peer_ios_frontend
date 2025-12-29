//
//  AppTab.swift
//  Environment
//
//  Created by Artem Vasin on 29.12.25.
//

import Foundation

public enum AppTab: Int, Identifiable, CaseIterable {
    case feed
    case newPost
    case wallet
    case shop
    case profile

    public var id: Int { rawValue }
}
