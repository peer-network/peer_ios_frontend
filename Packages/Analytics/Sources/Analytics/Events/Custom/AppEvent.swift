//
//  AppEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 23.04.25.
//

public enum AppEvent: AnalyticsEvent {
    case launch

    public var eventType: String {
        switch self {
            case .launch:
                return "app_launch"
        }
    }

    public var eventParameters: [String : Any]? {
        switch self {
            case .launch:
                return nil
        }
    }
}
