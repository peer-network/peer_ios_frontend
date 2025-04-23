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
    // TODO: Improvement for the future: observe UIApplication.willResignActiveNotification to stop and resume tracking while the app goes to the background and back
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    deinit {
        stopTrackingAllScreenTimes()
    }

    public func track(_ event: AnalyticsEvent) {
        Task(priority: .background) {
            await trackEvent(event)
        }
    }

    private func trackEvent(_ event: AnalyticsEvent) async {
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

        var parameters = event.eventParameters ?? [:]

        parameters["appVersion"] = bundleVersion
        parameters["appBuild"] = buildVersion
        parameters["iOSVersion"] = await UIDevice.current.systemVersion
        parameters["localeId"] = Locale.current.identifier

        Analytics.logEvent(event.eventType, parameters: parameters)
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
}
