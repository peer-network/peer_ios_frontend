//
//  ViewVisibilityModifier.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI

struct ViewVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0

    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}


struct ViewVisibilityModifier: ViewModifier {
    let viewed: Bool
    let viewAction: () -> Void
    @State private var visibilityTimer: Timer?

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { checkVisibility(geometry: geometry) }
                        .onChange(of: geometry.frame(in: .global)) {
                            checkVisibility(geometry: geometry)
                        }
                }
            )
    }

    private func checkVisibility(geometry: GeometryProxy) {
        guard !viewed else { return }

        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        let visibleHeight = max(0, min(frame.maxY, screenHeight) - max(frame.minY, 0))
        let percentageVisible = visibleHeight / frame.height

        if percentageVisible >= 0.7 {
            if visibilityTimer == nil {
                visibilityTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    visibilityTimer = nil
                    viewAction()
                }
            }
        } else {
            visibilityTimer?.invalidate()
            visibilityTimer = nil
        }
    }
}
