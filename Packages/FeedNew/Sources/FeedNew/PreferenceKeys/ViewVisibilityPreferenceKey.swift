//
//  ViewVisibilityPreferenceKey.swift
//  FeedNew
//
//  Created by Artem Vasin on 18.03.25.
//

import SwiftUICore

struct ViewVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0

    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}
