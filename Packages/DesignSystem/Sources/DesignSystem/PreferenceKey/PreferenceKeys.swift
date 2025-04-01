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
