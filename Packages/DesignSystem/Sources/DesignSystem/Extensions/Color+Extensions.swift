//
//  Color+Extensions.swift
//  DesignSystem
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI

extension Color {
    public static var brand: Color {
        Color(red: 187 / 255, green: 59 / 255, blue: 226 / 255)
    }
    
    public static var primaryBackground: Color {
        Color(red: 16 / 255, green: 21 / 255, blue: 35 / 255)
    }
    
    public static var secondaryBackground: Color {
        Color(red: 30 / 255, green: 35 / 255, blue: 62 / 255)
    }
    
    public static var label: Color {
        Color(.label)
    }
}

extension Color: @retroactive RawRepresentable {
    public init?(rawValue: Int) {
        let red = Double((rawValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rawValue & 0x00FF00) >> 8) / 0xFF
        let blue = Double(rawValue & 0x0000FF) / 0xFF
        self = Color(red: red, green: green, blue: blue)
    }
    
    public var rawValue: Int {
        guard let coreImageColor else {
            return 0
        }
        let red = Int(coreImageColor.red * 255 + 0.5)
        let green = Int(coreImageColor.green * 255 + 0.5)
        let blue = Int(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }
    
    private var coreImageColor: CIColor? {
        CIColor(color: .init(self))
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - New Design System

public extension Color {
    static let backgroundDark = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let glowBlue = Color(red: 0.47, green: 0.69, blue: 1)
    static let warning = Color(red: 1, green: 0.4, blue: 0.4)
    static let icons = Color(red: 0.48, green: 0.48, blue: 0.48)
    
    static let passwordBarsEmpty = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let passwordBarsRed = Color(red: 1, green: 0.4, blue: 0.4)
    static let passwordBarsYellow = Color(red: 1, green: 0.8, blue: 0.4)
    static let passwordBarsGreen = Color(red: 0.67, green: 1, blue: 0.4)
    
    static let hashtag = Color(red: 0, green: 0.41, blue: 1)
    
    static let redAccent = Color(red: 1, green: 0.231, blue: 0.231)
    static let textSuggestions = Color(red: 0.145, green: 0.145, blue: 0.145).opacity(0.5)
    static let textActive = Color(red: 0.145, green: 0.145, blue: 0.145)
    static let darkInactive = Color(red: 0.19, green: 0.19, blue: 0.19)
    static let lightBlue = Color(red: 0.47, green: 0.69, blue: 1).opacity(0.2)
    static let shortVideo = Color(red: 0, green: 0.41, blue: 1).opacity(0.5)
}
