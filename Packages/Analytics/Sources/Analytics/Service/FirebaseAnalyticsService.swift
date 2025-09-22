//
//  FirebaseAnalyticsService.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import Foundation
import Combine
import FirebaseAnalytics

public final class FirebaseAnalyticsService: AnalyticsServiceProtocol {
    private var screenTimeStack: [ScreenTimeTracker] = []
    private var cancellables = Set<AnyCancellable>()

    public init() {
        setupAppStateObservers()
    }

    deinit {
        stopTrackingAllScreenTimes()
    }

    public func track(_ event: AnalyticsEvent) {
        Task.detached(priority: .background) { [weak self] in
            await self?.trackEvent(event)
        }
    }

    private func trackEvent(_ event: AnalyticsEvent) async {
        var parameters = event.eventParameters ?? [:]

        // Enrich with common context (keep names short to save your 25-param budget)
        parameters["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        parameters["app_build"]   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        parameters["ios_version"] = await UIDevice.current.systemVersion
        parameters["locale_id"]   = Locale.current.identifier

        // Coerce values to GA4-friendly types
        let coerced = Self.coerceParameters(parameters)

        Analytics.logEvent(event.eventType, parameters: coerced)
    }

    private static func coerceParameters(_ params: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (k, v) in params {
            switch v {
                case let b as Bool:
                    result[k] = NSNumber(value: b)   // true->1, false->0
                case let i as Int:
                    result[k] = i
                case let d as Double:
                    result[k] = d
                case let s as String:
                    result[k] = s
                case let n as NSNumber:
                    result[k] = n
                default:
                    // Last resort: stringify to avoid dropping data
                    result[k] = String(describing: v)
            }
        }
        return result
    }

    public func trackScreenView(_ screen: ScreenTrackable) {
        Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: screen.screenName,
                AnalyticsParameterScreenClass: screen.screenClass,
            ]
        )
    }

    public func startTrackingScreenTime(_ screen: ScreenTrackable) {
        // Track screen view
        trackScreenView(screen)

        // Push new screen to stack with unique ID
        let screenToTrack = ScreenTimeTracker(
            id: UUID(),
            screen: screen,
            startTime: Date()
        )
        screenTimeStack.append(screenToTrack)
    }

    private func stopTrackingLastScreenTime() {
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
        track(ScreenTimeEvent(
            screenName: screen.screenName,
            screenClass: screen.screenClass,
            duration: duration
        ))
    }

    private func stopTrackingAllScreenTimes() {
        while !screenTimeStack.isEmpty {
            stopTrackingLastScreenTime()
        }
    }

    public func setUserID(_ userID: String) {
        Analytics.setUserID(userID)
    }

    public func resetUserID() {
        Analytics.setUserID(nil)
    }

    private func setupAppStateObservers() {
        // Handle app going to background
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppBackgrounded()
            }
            .store(in: &cancellables)

        // Handle app returning to foreground
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppForegrounded()
            }
            .store(in: &cancellables)
    }

    private func handleAppBackgrounded() {
        let now = Date()

        for index in screenTimeStack.indices where screenTimeStack[index].screen.shouldSuspendWhenBackgrounded {
            screenTimeStack[index].backgroundStartTime = now
        }
    }

    private func handleAppForegrounded() {
        let now = Date()

        for index in screenTimeStack.indices where screenTimeStack[index].screen.shouldSuspendWhenBackgrounded {
            if let backgroundStartTime = screenTimeStack[index].backgroundStartTime {
                let backgroundDuration = now.timeIntervalSince(backgroundStartTime)
                screenTimeStack[index].startTime = screenTimeStack[index].startTime.addingTimeInterval(backgroundDuration)
                screenTimeStack[index].backgroundStartTime = nil

                print("\(screenTimeStack[index].screen.screenName) - \(screenTimeStack[index].startTime)")
            }
        }
    }
}
