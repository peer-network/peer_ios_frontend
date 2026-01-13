//
//  PreferenceKeys.swift
//  DesignSystem
//
//  Created by Артем Васин on 07.02.25.
//

import SwiftUI

public struct OffsetKeyRect: PreferenceKey {
    public static var defaultValue: CGRect = .zero
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

public struct ScrollOffsetKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
