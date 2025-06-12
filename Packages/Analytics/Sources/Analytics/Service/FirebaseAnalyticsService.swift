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
