//
//  TargetButtonStyle.swift
//  DesignSystem
//
//  Created by Артем Васин on 29.01.25.
//

import SwiftUI

public struct TargetButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.customFont(weight: .regular, size: .title))
            .bold()
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Gradients.activeButtonBlue)
            .ifCondition(configuration.isPressed || !isEnabled) {
                $0.overlay(Color.black.opacity(0.3))
            }
            .cornerRadius(24)
            .contentShape(Rectangle())
    }
}
