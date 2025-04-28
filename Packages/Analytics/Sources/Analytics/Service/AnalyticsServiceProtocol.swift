//
//  AnalyticsServiceProtocol.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

import Foundation

struct ScreenTimeTracker {
    let id: UUID
    let screen: ScreenTrackable
    var startTime: Date
}

public protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent)
    func trackScreenView(_ screen: ScreenTrackable)
    func startTrackingScreenTime(_ screen: ScreenTrackable)
    func stopTrackingScreenTime(_ screen: ScreenTrackable)
    func setUserID(_ userID: String)
    func resetUserID()
}
