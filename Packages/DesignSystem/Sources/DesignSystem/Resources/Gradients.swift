//
//  Gradients.swift
//  DesignSystem
//
//  Created by Артем Васин on 29.01.25.
//

import SwiftUI

@frozen
public enum Gradients {
    public static let activeButtonBlue = LinearGradient(
        stops: [
            Gradient.Stop(color: Colors.glowBlue, location: 0.00),
            Gradient.Stop(color: Colors.hashtag, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0.5),
        endPoint: UnitPoint(x: 1, y: 0.5)
    )

    public static let blackHover = LinearGradient(
        stops: [
            Gradient.Stop(color: .black.opacity(0), location: 0.00),
            Gradient.Stop(color: .black, location: 0.50),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )

    public static let walletBG1 = EllipticalGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.47, green: 0.69, blue: 1), location: 0.00),
            Gradient.Stop(color: Color(red: 0, green: 0.75, blue: 1).opacity(0), location: 1.00),
        ],
        center: UnitPoint(x: 0.65, y: 0.8)
    )
    
    public static let walletBG2 = EllipticalGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1), location: 0.00),
            Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1).opacity(0), location: 1.00),
        ],
        center: UnitPoint(x: 0.65, y: 0.8)
    )

    public static let postCreationFloatingButtonsBG = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0), location: 0.00),
            Gradient.Stop(color: Colors.blackDark, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )
}
