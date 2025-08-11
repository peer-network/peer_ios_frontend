//
//  EnvironmentValues+Extensions.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import SwiftUICore

struct AnalyticsEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnalyticsServiceProtocol = MockAnalyticsService()
}

public extension EnvironmentValues {
    var analytics: AnalyticsServiceProtocol {
        get { self[AnalyticsEnvironmentKey.self] }
        set { self[AnalyticsEnvironmentKey.self] = newValue }
    }
}
