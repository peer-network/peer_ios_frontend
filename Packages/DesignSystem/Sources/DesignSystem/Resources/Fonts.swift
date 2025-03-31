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
    case headline = 17
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
