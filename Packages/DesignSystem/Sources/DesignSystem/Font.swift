//
//  Font.swift
//  DesignSystem
//
//  Created by Артем Васин on 31.12.24.
//

import SwiftUI

@MainActor
extension Font {
    private static let title = 28.0
    private static let headline = 17.0
    private static let body = 17.0
    private static let callout = 16.0
    private static let subheadline = 15.0
    private static let footnote = 13.0
    private static let caption = 12.0
    
    private static func customFont(size: CGFloat, relativeTo textStyle: TextStyle) -> Font {
        if let chosenFont = Theme.shared.chosenFont {
            if chosenFont.fontName == ".AppleSystemUIFontRounded-Regular" {
                return .system(size: size, design: .rounded)
            } else {
                return .custom(chosenFont.fontName, size: size, relativeTo: textStyle)
            }
        }
        
        return .system(size: size, design: .default)
    }
    
    private static func customUIFont(size: CGFloat) -> UIFont {
        if let chosenFont = Theme.shared.chosenFont {
            return chosenFont.withSize(size)
        }
        return .systemFont(ofSize: size)
    }
    
    private static func userScaledFontSize(baseSize: CGFloat) -> CGFloat {
        UIFontMetrics.default.scaledValue(for: baseSize * Theme.shared.fontSizeScale)
    }
    
    public static var scaledHeadline: Font {
        customFont(size: userScaledFontSize(baseSize: headline), relativeTo: .headline).weight(
            .semibold)
    }
    
    public static var scaledSubheadline: Font {
        customFont(size: userScaledFontSize(baseSize: subheadline), relativeTo: .subheadline)
    }
    
    public static var scaledTitle: Font {
        customFont(size: userScaledFontSize(baseSize: title), relativeTo: .title)
    }
    
    public static var scaledBody: Font {
        customFont(size: userScaledFontSize(baseSize: body), relativeTo: .body)
    }
    
    public static var scaledBodyFont: UIFont {
        customUIFont(size: userScaledFontSize(baseSize: body))
    }
    
    public static var scaledBodyUIFont: UIFont {
        customUIFont(size: userScaledFontSize(baseSize: body))
    }
    
    public static var scaledCaption: Font {
        customFont(size: userScaledFontSize(baseSize: caption), relativeTo: .caption)
    }
    
    public static var scaledFootnote: Font {
        customFont(size: userScaledFontSize(baseSize: footnote), relativeTo: .footnote)
    }
}

extension UIFont {
    public func rounded() -> UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
