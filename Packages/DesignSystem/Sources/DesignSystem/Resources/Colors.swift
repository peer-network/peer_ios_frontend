//
//  Colors.swift
//  DesignSystem
//
//  Created by Artem Vasin on 04.04.25.
//

import SwiftUI

@frozen
public enum Colors {
    public static let textActive = Color(red: 0.145, green: 0.145, blue: 0.145)
    public static let textSuggestions = Color(red: 0.145, green: 0.145, blue: 0.145).opacity(0.5)
    public static let redAccent = Color(red: 1, green: 0.231, blue: 0.231)
    public static let hashtag = Color(red: 0, green: 0.412, blue: 1)
    public static let shortVideo = Color(red: 0, green: 0.412, blue: 1).opacity(0.5)
    public static let blackDark = Color(red: 0.145, green: 0.145, blue: 0.145)
    public static let inactiveDark = Color(red: 0.196, green: 0.196, blue: 0.196)
    public static let blueLight = Color(red: 0.467, green: 0.686, blue: 1).opacity(0.2)
    public static let whitePrimary = Color(red: 1, green: 1, blue: 1)
    public static let whiteSecondary = Color(red: 1, green: 1, blue: 1).opacity(0.5)

    public static let passwordBarsEmpty = Color(red: 0.85, green: 0.85, blue: 0.85)
    public static let passwordBarsRed = Color(red: 1, green: 0.4, blue: 0.4)
    public static let passwordBarsYellow = Color(red: 1, green: 0.8, blue: 0.4)
    public static let passwordBarsGreen = Color(red: 0.67, green: 1, blue: 0.4)

    public static let warning = Color(red: 1, green: 0.4, blue: 0.4)
    public static let greyIcons = Color(red: 0.48, green: 0.48, blue: 0.48)
    public static let glowBlue = Color(red: 0.47, green: 0.69, blue: 1)
}
