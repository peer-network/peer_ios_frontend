//
//  SearchType.swift
//  Explore
//
//  Created by Artem Vasin on 12.05.25.
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
