//
//  SystemPopupOverlayViewModifier.swift
//  DesignSystem
//
//  Created by Artem Vasin on 28.10.25.
//

import SwiftUI

public struct SystemPopupOverlay: ViewModifier {
    @ObservedObject var manager: SystemPopupManager

    public func body(content: Content) -> some View {
        ZStack {
            content

            if let builder = manager.presentedPopupBuilder {
                // scrim
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { manager.dismiss() }

                // popup
                builder()
                    .padding(20)
                    .shadow(color: .black.opacity(0.1), radius: 2.66272, x: 0, y: 6.84698)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: manager.presentedPopupBuilder != nil)
    }
}


public extension View {
    func systemPopupOverlay(_ manager: SystemPopupManager = .shared) -> some View {
        modifier(SystemPopupOverlay(manager: manager))
    }
}
