//
//  ScreenViewEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import FirebaseAnalytics

struct ScreenViewEvent: AnalyticsEvent {
    let screenName: String
    let screenClass: String

    var eventType: String { AnalyticsEventScreenView }
    var eventParameters: [String: Any]? {
        [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ]
    }
}
