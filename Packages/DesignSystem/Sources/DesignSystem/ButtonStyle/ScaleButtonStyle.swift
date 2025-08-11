//
//  ScaleButtonStyle.swift
//  DesignSystem
//
//  Created by Artem Vasin on 19.03.25.
//

import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(.linear(duration: 0.2)) {
                $0.scaleEffect(configuration.isPressed ? 0.9 : 1)
            }
    }
}
