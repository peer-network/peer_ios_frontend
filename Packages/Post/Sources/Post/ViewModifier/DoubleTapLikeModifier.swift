//
//  DoubleTapLikeModifier.swift
//  Post
//
//  Created by Artem Vasin on 14.08.25.
//

import SwiftUI
import DesignSystem

struct DoubleTapLikeModifier: ViewModifier {
    @State private var activeAnimations: [LikeAnimation] = []
    let action: () async throws -> Void
    let onError: (Error) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                ZStack {
                    ForEach(activeAnimations) { animation in
                        HeartView(animation: animation)
                    }
                }
                .allowsHitTesting(false)
            }
            .onTapGesture(count: 2) { location in
                handleDoubleTap(at: location)
            }
    }

    private func handleDoubleTap(at location: CGPoint) {
        let animation = LikeAnimation(position: location)
        activeAnimations.append(animation)

        // Animate
        withAnimation(.spring()) {
            if let index = activeAnimations.firstIndex(where: { $0.id == animation.id }) {
                activeAnimations[index].phase = .expanding
            }
        }

        withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
            if let index = activeAnimations.firstIndex(where: { $0.id == animation.id }) {
                activeAnimations[index].phase = .fading
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            activeAnimations.removeAll { $0.id == animation.id }
        }

        // Action
        Task {
            do {
                try await action()
            } catch {
                onError(error)
            }
        }
    }
}

private struct LikeAnimation: Identifiable {
    enum Phase {
        case appearing
        case expanding
        case fading
    }

    let id = UUID()
    let position: CGPoint
    var phase: Phase = .appearing
}

private struct HeartView: View {
    let animation: LikeAnimation

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 80))
            .foregroundColor(Colors.redAccent)
            .scaleEffect(animation.phase == .appearing ? 1.8 : 1.0)
            .opacity(animation.phase == .fading ? 0 : 1)
            .rotationEffect(.degrees(animation.phase == .appearing ? .random(in: -30...30) : 0))
            .offset(
                x: animation.position.x - 40,
                y: animation.position.y - 40 + (animation.phase == .fading ? -100 : 0)
            )
            .shadow(color: .pink.opacity(0.5), radius: 15)
    }
}

extension View {
    func doubleTapToLike(
        perform action: @escaping () async throws -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        self.modifier(DoubleTapLikeModifier(action: action, onError: onError))
    }
}
