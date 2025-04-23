//
//  AnalyticsEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

public protocol AnalyticsEvent {
    var eventType: String { get }
    var eventParameters: [String: Any]? { get }
}
