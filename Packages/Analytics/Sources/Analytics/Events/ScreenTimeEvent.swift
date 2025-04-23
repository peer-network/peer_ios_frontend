//
//  ScreenTimeEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import Foundation

struct ScreenTimeEvent: AnalyticsEvent {
    let screenName: String
    let screenClass: String
    let duration: TimeInterval

    var eventType: String { "screen_time" }
    var eventParameters: [String: Any]? {
        [
            "screen_name": screenName,
            "screen_class": screenClass,
            "duration_seconds": duration
        ]
    }
}
