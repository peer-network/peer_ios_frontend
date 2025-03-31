//
//  TextStyle.swift
//  DesignSystem
//
//  Created by Артем Васин on 19.12.24.
//

import SwiftUI

public enum TextStyle {
    case displayLarge
    case headlineSmall
    case headlineMedium
    case headlineLarge
    case titleSmall
    case titleMedium
    case titleLarge
    case bodySmall
    case bodyMedium
    case bodyLarge
    case labelSmall
    case labelMedium
    case labelLarge
    case objectButtonSemiBold
    case objectButtonRegular
    case objectCounterSemiBold
    
    public var fontSize: CGFloat {
        switch self {
            case .displayLarge:
                30
            case .headlineSmall:
                14
            case .headlineMedium:
                18
            case .headlineLarge:
                22
            case .titleSmall:
                14
            case .titleMedium:
                14
            case .titleLarge:
                18
            case .bodySmall:
                12
            case .bodyMedium:
                14
            case .bodyLarge:
                20
            case .labelSmall:
                11
            case .labelMedium:
                12
            case .labelLarge:
                14
            case .objectButtonSemiBold:
                14
            case .objectButtonRegular:
                12
            case .objectCounterSemiBold:
                12
        }
    }
    
    public var fontWeight: Font.Weight {
        switch self {
            case .displayLarge:
                    .semibold
            case .headlineSmall:
                    .semibold
            case .headlineMedium:
                    .semibold
            case .headlineLarge:
                    .semibold
            case .titleSmall:
                    .regular
            case .titleMedium:
                    .semibold
            case .titleLarge:
                    .semibold
            case .bodySmall:
                    .regular
            case .bodyMedium:
                    .regular
            case .bodyLarge:
                    .regular
            case .labelSmall:
                    .regular
            case .labelMedium:
                    .regular
            case .labelLarge:
                    .regular
            case .objectButtonSemiBold:
                    .semibold
            case .objectButtonRegular:
                    .regular
            case .objectCounterSemiBold:
                    .semibold
        }
    }
}
