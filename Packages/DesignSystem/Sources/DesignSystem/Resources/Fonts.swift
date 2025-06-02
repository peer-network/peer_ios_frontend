//
//  Fonts.swift
//  DesignSystem
//
//  Created by Артем Васин on 29.01.25.
//

import SwiftUI

public enum FontType: String {
    case poppins
    
    public var name: String {
        self.rawValue.capitalized
    }
}

public enum FontWeight: String {
    case extraLight
    case light
    case thin
    case regular
    case medium
    case semiBold
    case bold
    case extraBold
    case black
    
    case extraLightItalic
    case lightItalic
    case thinItalic
    case regularItalic
    case mediumItalic
    case semiBoldItalic
    case boldItalic
    case extraBoldItalic
    case blackItalic
    
    public var name: String {
        "-" + self.rawValue.capitalized
    }
}

public enum FontSize: CGFloat {
    case title = 17
    case body = 14
    case footnote = 12
    case footnoteSmall = 10
}

public enum FontSizeNew: CGFloat {
    case title = 17
    case headline = 14
    case subheadline = 13
    case body = 11
    case callout = 10
}

@available(iOS 14, *)
public extension Font {
    static func customFont(type: FontType = .poppins, weight: FontWeight, size: FontSize) -> Font {
        .custom(type.name + weight.name, size: size.rawValue)
    }
    
    static func customFont(type: FontType = .poppins, weight: FontWeight = .regular, style: UIFont.TextStyle) -> Font {
        .custom(type.name + weight.name, size: UIFont.preferredFont(forTextStyle: style).pointSize)
    }
    
    static func customFont(type: FontType = .poppins, weight: FontWeight, size: FontSize, relativeTo: TextStyle) -> Font {
        .custom(type.name + weight.name, size: size.rawValue, relativeTo: relativeTo)
    }
}

// MARK: - UIKit Extension

private extension FontWeight {
    var systemWeight: UIFont.Weight {
        switch self {
        case .extraLight, .extraLightItalic: return .ultraLight
        case .light, .lightItalic: return .light
        case .thin, .thinItalic: return .thin
        case .regular, .regularItalic: return .regular
        case .medium, .mediumItalic: return .medium
        case .semiBold, .semiBoldItalic: return .semibold
        case .bold, .boldItalic: return .bold
        case .extraBold, .extraBoldItalic: return .heavy
        case .black, .blackItalic: return .black
        }
    }
}

public extension UIFont {
    static func customFont(type: FontType = .poppins, weight: FontWeight, size: FontSize) -> UIFont {
        customFont(type: type, weight: weight, size: size.rawValue)
    }

    static func customFont(type: FontType = .poppins, weight: FontWeight, size: CGFloat) -> UIFont {
        let fontName = type.name + weight.name
        guard let font = UIFont(name: fontName, size: size) else {
            print("Warning: Failed to load font \(fontName). Falling back to system font.")
            return UIFont.systemFont(ofSize: size, weight: weight.systemWeight)
        }
        return font
    }

    static func customFont(type: FontType = .poppins, weight: FontWeight = .regular, style: UIFont.TextStyle) -> UIFont {
        let fontName = type.name + weight.name
        let metrics = UIFontMetrics(forTextStyle: style)
        let defaultSize = UIFont.preferredFont(forTextStyle: style).pointSize

        guard let font = UIFont(name: fontName, size: defaultSize) else {
            print("Warning: Failed to load font \(fontName). Falling back to system font.")
            return metrics.scaledFont(for: UIFont.systemFont(ofSize: defaultSize, weight: weight.systemWeight))
        }

        return metrics.scaledFont(for: font)
    }
}
