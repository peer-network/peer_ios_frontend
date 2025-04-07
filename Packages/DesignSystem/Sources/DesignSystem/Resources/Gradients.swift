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
}
