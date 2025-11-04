//
//  Fonts.swift
//  DesignSystem
//
//  Created by Артем Васин on 29.01.25.
//

import SwiftUI

@frozen
public enum FontType: String {
    case poppins
    
    public var name: String {
        self.rawValue.capitalized
    }
}

@frozen
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

@frozen
public enum FontSize: CGFloat {
    case title = 17
    case body = 14
    case footnote = 12
    case footnoteSmall = 10
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


// MARK: - Design system finilize

// MARK: - Font Type
@frozen
public enum FontFamily2: String {
    case poppins

    public var name: String {
        self.rawValue.capitalized
    }
}

// MARK: - Font Weight
@frozen
public enum FontWeight2: String, CaseIterable {
    case extraLight = "ExtraLight"
    case light = "Light"
    case thin = "Thin"
    case regular = "Regular"
    case medium = "Medium"
    case semiBold = "SemiBold"
    case bold = "Bold"
    case extraBold = "ExtraBold"
    case black = "Black"

    case extraLightItalic = "ExtraLightItalic"
    case lightItalic = "LightItalic"
    case thinItalic = "ThinItalic"
    case regularItalic = "RegularItalic"
    case mediumItalic = "MediumItalic"
    case semiBoldItalic = "SemiBoldItalic"
    case boldItalic = "BoldItalic"
    case extraBoldItalic = "ExtraBoldItalic"
    case blackItalic = "BlackItalic"

    public var suffix: String {
        "-" + self.rawValue
    }

    public var isItalic: Bool {
        rawValue.hasSuffix("Italic")
    }
}

// MARK: - Font Size
@frozen
public enum FontSize2 {
    // Titles
    case extraLargeTitle
    case largeTitle

    // Button
    case button

    // Body
    case body

    // Label
    case smallLabel

    case dummyDesignSystem

    var value: CGFloat {
        switch self {
            case .extraLargeTitle: return 30
            case .largeTitle: return 20
            case .button: return 17
            case .body: return 14
            case .smallLabel: return 11
            case .dummyDesignSystem: return 8
        }
    }
}

// MARK: - Font Style
public struct AppFont {
    let family: FontFamily2
    let weight: FontWeight2
    let size: FontSize2

    public init(family: FontFamily2 = .poppins, weight: FontWeight2, size: FontSize2) {
        self.family = family
        self.weight = weight
        self.size = size
    }

    var fontName: String {
        family.name + weight.suffix
    }

    var pointSize: CGFloat {
        size.value
    }

    // Title styles
    public static let extraLargeTitleBold = AppFont(weight: .bold, size: .extraLargeTitle)
    public static let extraLargeTitleBoldItalic = AppFont(weight: .boldItalic, size: .extraLargeTitle)
    public static let extraLargeTitleRegular = AppFont(weight: .regular, size: .extraLargeTitle)
    public static let largeTitleBold = AppFont(weight: .bold, size: .largeTitle)
    public static let largeTitleRegular = AppFont(weight: .regular, size: .largeTitle)

    // Button styles
    public static let buttonBold = AppFont(weight: .bold, size: .button)
    public static let buttonRegular = AppFont(weight: .regular, size: .button)

    // Body styles
    public static let bodyBold = AppFont(weight: .bold, size: .body)
    public static let bodyBoldItalic = AppFont(weight: .boldItalic, size: .body)
    public static let bodyRegular = AppFont(weight: .regular, size: .body)

    // Label styles
    public static let smallLabelBold = AppFont(weight: .bold, size: .smallLabel)
    public static let smallLabelBoldItalic = AppFont(weight: .boldItalic, size: .smallLabel)
    public static let smallLabelRegular = AppFont(weight: .regular, size: .smallLabel)
}

// MARK: - SwiftUI Extension
@available(iOS 14, *)
public extension Font {
    static func custom(_ appFont: AppFont) -> Font {
        .custom(appFont.fontName, size: appFont.pointSize)
    }

    static func custom(_ appFont: AppFont, relativeTo textStyle: TextStyle) -> Font {
        .custom(appFont.fontName, size: appFont.pointSize, relativeTo: textStyle)
    }

    static func custom(_ appFont: AppFont, fixedSize: Bool) -> Font {
        if fixedSize {
            return .custom(appFont.fontName, fixedSize: appFont.pointSize)
        } else {
            return .custom(appFont.fontName, size: appFont.pointSize)
        }
    }
}

// MARK: - UIKit Extension
private extension FontWeight2 {
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
    static func custom(_ appFont: AppFont) -> UIFont {
        guard let font = UIFont(name: appFont.fontName, size: appFont.pointSize) else {
            print("Warning: Failed to load font \(appFont.fontName). Falling back to system font.")
            return systemFont(ofSize: appFont.pointSize, weight: appFont.weight.systemWeight)
        }
        return font
    }

    static func custom(_ appFont: AppFont, compatibleWith traitCollection: UITraitCollection?) -> UIFont {
        let font = UIFont.custom(appFont)
        return UIFontMetrics.default.scaledFont(for: font, compatibleWith: traitCollection)
    }

    static func custom(_ appFont: AppFont, forTextStyle textStyle: UIFont.TextStyle, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        let font = UIFont.custom(appFont)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font, compatibleWith: traitCollection)
    }
}

// MARK: - View Modifier for SwiftUI
public struct AppFontModifier: ViewModifier {
    let appFont: AppFont

    public func body(content: Content) -> some View {
        content
            .font(.custom(appFont))
    }
}

public extension View {
    /// Applies custom app font to the view
    func appFont(_ appFont: AppFont) -> some View {
        self.modifier(AppFontModifier(appFont: appFont))
    }

    /// Applies custom app font with dynamic type scaling
    func appFont(_ appFont: AppFont, relativeTo textStyle: Font.TextStyle) -> some View {
        self.font(.custom(appFont, relativeTo: textStyle))
    }
}
