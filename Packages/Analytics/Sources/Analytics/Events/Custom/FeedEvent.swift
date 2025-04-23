//
//  FeedEvent.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

public enum FeedEvent: AnalyticsEvent {
    case like
    case dislike
    case view

    public var eventType: String {
        switch self {
            case .like:
                return "post_like"
            case .dislike:
                return "post_dislike"
            case .view:
                return "post_view"
        }
    }

    public var eventParameters: [String : Any]? {
        switch self {
            case .like:
                return nil
            case .dislike:
                return nil
            case .view:
                return nil
        }
    }
}
