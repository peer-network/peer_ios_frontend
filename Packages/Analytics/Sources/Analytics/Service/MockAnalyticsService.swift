//
//  MockAnalyticsService.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import Foundation

public final class MockAnalyticsService: AnalyticsServiceProtocol {
    // MARK: - Tracked Data
    public private(set) var trackedEvents: [(type: String, parameters: [String: Any]?)] = []
    public private(set) var trackedScreenViews: [(name: String, class: String)] = []
    public private(set) var screenTimeEvents: [(screenName: String, screenClass: String, duration: TimeInterval)] = []
    public private(set) var setUserIDCalls: [String?] = []
    private var screenTimeStack: [ScreenTimeTracker] = []

    // MARK: - Configuration
    public let shouldPrintLogs: Bool

    // MARK: - Initialization
    public init(shouldPrintLogs: Bool = false) {
        self.shouldPrintLogs = shouldPrintLogs
    }

    // MARK: - AnalyticsServiceProtocol Implementation
    public func track(_ event: AnalyticsEvent) {
        trackedEvents.append((event.eventType, event.eventParameters))
        if shouldPrintLogs {
            print("[MockAnalytics] Tracked event: \(event.eventType)")
        }
    }

    public func trackScreenView(_ screen: ScreenTrackable) {
        trackedScreenViews.append((screen.screenName, screen.screenClass))
        if shouldPrintLogs {
            print("[MockAnalytics] Screen view: \(screen.screenName)")
        }
    }

    public func startTrackingScreenTime(_ screen: ScreenTrackable) {
        // Track screen view
        trackScreenView(screen)

        let screenToTrack = ScreenTimeTracker(
            id: UUID(),
            screen: screen,
            startTime: Date()
        )
        screenTimeStack.append(screenToTrack)

        if shouldPrintLogs {
            print("[MockAnalytics] Started tracking: \(screen.screenName)")
        }
    }

    public func stopTrackingLastScreenTime() {
        guard let last = screenTimeStack.popLast() else { return }
        
        let duration = Date().timeIntervalSince(last.startTime)
        trackScreenTime(for: last.screen, duration: duration)
    }

    public func stopTrackingScreenTime(_ screen: ScreenTrackable) {
        if let firstIndex = screenTimeStack.firstIndex(where: { $0.screen.screenName == screen.screenName }) {
            let removed = screenTimeStack.remove(at: firstIndex)
            let duration = Date().timeIntervalSince(removed.startTime)
            trackScreenTime(for: removed.screen, duration: duration)
        }
    }

    private func trackScreenTime(for screen: ScreenTrackable, duration: TimeInterval) {
        screenTimeEvents.append((screen.screenName, screen.screenClass, duration))
        if shouldPrintLogs {
            print("[MockAnalytics] Screen time: \(screen.screenName) - \(duration.rounded())s")
        }
    }

    public func setUserID(_ userID: String) {
        setUserIDCalls.append(userID)

        if shouldPrintLogs {
            print("[MockAnalytics] Set user ID: \(userID)")
        }
    }

    public func resetUserID() {
        setUserIDCalls.append(nil)

        if shouldPrintLogs {
            print("[MockAnalytics] Reset user ID")
        }
    }
}

// MARK: - Test Helpers

extension MockAnalyticsService {
    public func reset() {
        trackedEvents.removeAll()
        trackedScreenViews.removeAll()
        screenTimeEvents.removeAll()
        setUserIDCalls.removeAll()
        screenTimeStack.removeAll()
    }

    public func currentScreenNames() -> [String] {
        return screenTimeStack.map { $0.screen.screenName }
    }

    public func isTracking(screen: ScreenTrackable) -> Bool {
        screenTimeStack.contains {
            $0.screen.screenName == screen.screenName &&
            $0.screen.screenClass == screen.screenClass
        }
    }
}
