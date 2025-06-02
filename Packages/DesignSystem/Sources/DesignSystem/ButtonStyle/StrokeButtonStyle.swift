//
//  StrokeButtonStyle.swift
//  DesignSystem
//
//  Created by Artem Vasin on 16.05.25.
//

import SwiftUI

public struct StrokeButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.customFont(weight: .bold, style: .footnote))
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background {
                Colors.blackDark

                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Colors.whitePrimary, lineWidth: 1)
            }
            .ifCondition(configuration.isPressed || !isEnabled) {
                $0.overlay(Color.black.opacity(0.3))
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .contentShape(Rectangle())
    }
}
