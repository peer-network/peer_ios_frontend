//
//  PopupTransparentStyleView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 17.03.25.
//

import SwiftUI

public struct PopupTransparentStyleView<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    /// View Properties
    @State private var viewSize: CGSize = .zero

    public init(cornerRadius: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(20)
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .background {
                backgroundView()
            }
            .compositingGroup()
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                viewSize = newValue
            }
    }

    @ViewBuilder
    private func backgroundView() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Colors.inactiveDark)
    }
}

extension CGSize: @retroactive @unchecked Sendable { }
