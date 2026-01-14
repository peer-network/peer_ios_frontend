//
//  SearchType.swift
//  FeedNew
//
//  Created by Artem Vasin on 14.01.26.
//

enum SearchType: String {
    case none
    case username = "@username"
    case tag = "#tag"
    case title = "Title"

    var prefix: String {
        switch self {
            case .username:
                return "@"
            case .tag:
                return "#"
            default:
                return ""
        }
    }
}
