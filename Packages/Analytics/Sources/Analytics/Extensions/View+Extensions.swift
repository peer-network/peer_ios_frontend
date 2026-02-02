//
//  View+Extensions.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import SwiftUI

struct ScreenTrackingModifier: ViewModifier {
    let screen: ScreenTrackable
    @Environment(\.analytics) private var analytics

    func body(content: Content) -> some View {
        content
            .onAppear {
                analytics.startTrackingScreenTime(screen)
            }
            .onDisappear {
                analytics.stopTrackingScreenTime(screen)
            }
    }
}

public extension View {
    func trackScreen(_ screen: ScreenTrackable) -> some View {
        modifier(ScreenTrackingModifier(screen: screen))
    }

    func analyticsService(_ service: AnalyticsServiceProtocol) -> some View {
        environment(\.analytics, service)
    }
}
