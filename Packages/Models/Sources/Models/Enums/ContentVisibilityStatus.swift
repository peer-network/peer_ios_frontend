//
//  ContentVisibilityStatus.swift
//  Models
//
//  Created by Artem Vasin on 11.11.25.
//

import GQLOperationsUser

public enum ContentVisibilityStatus {
    case normal
    case hidden
    case illegal

    static func normalizedValue(_ apiValue: GQLOperationsUser.ContentVisibilityStatus?) -> ContentVisibilityStatus {
        guard let apiValue else { return .normal }
        switch apiValue {
            case .normal:
                return .normal
            case .hidden:
                return .hidden
            case .illegal:
                return .illegal
        }
    }
}
