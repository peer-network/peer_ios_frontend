//
//  Gradients.swift
//  DesignSystem
//
//  Created by Артем Васин on 29.01.25.
//

import SwiftUI

@frozen
public enum Gradients {
    public static let blueGradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(red: 0.47, green: 0.69, blue: 1), location: 0.00),
            Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0.5),
        endPoint: UnitPoint(x: 1, y: 0.5)
    )
}
