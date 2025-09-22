//
//  OnboardingEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 18.09.25.
//

public struct OnboardingEvent: AnalyticsEvent {
    public let skipped: Bool

    public init(skipped: Bool) {
        self.skipped = skipped
    }

    public var eventType: String { "onboarding" }

    public var eventParameters: [String: Any]? {
        let params: [String: Any] = [
            "skipped": skipped
        ]
        return params
    }
}
