//
//  SkeletonModifier.swift
//  DesignSystem
//
//  Created by Artem Vasin on 14.04.25.
//

import SwiftUI

public extension View {
    func skeleton(isRedacted: Bool) -> some View {
        modifier(SkeletonModifier(isRedacted: isRedacted))
    }
}

private struct SkeletonModifier: ViewModifier {
    var isRedacted: Bool

    private let rotation: Double = 0
    private let animation = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)

    @State private var startTime: Date?
    @State private var animationID = UUID()
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .redacted(reason: isRedacted ? .placeholder : [])
            .overlay {
                if isRedacted {
                    TimelineView(.animation) { timeline in
                        GeometryReader { geometry in
                            let size = geometry.size
                            let skeletonWidth = size.width / 2
                            let blurRadius = max(skeletonWidth / 2, 30)
                            let totalTravel = size.width + skeletonWidth * 2 + blurRadius * 4
                            let progress = calculateProgress(at: timeline.date)

                            Rectangle()
                                .fill(scheme == .dark ? .white : .black)
                                .frame(width: skeletonWidth, height: size.height * 2)
                                .frame(height: size.height)
                                .blur(radius: blurRadius)
                                .rotationEffect(.init(degrees: rotation))
                                .offset(x: -skeletonWidth + progress * totalTravel)
                        }
                        .mask {
                            content.redacted(reason: .placeholder)
                        }
                        .blendMode(.softLight)
                    }
                    .onAppear { startAnimation() }
                    .onDisappear { resetAnimation() }
                    .onChange(of: isRedacted) { newValue in
                        newValue ? startAnimation() : resetAnimation()
                    }
                }
            }
    }

    private func calculateProgress(at currentTime: Date) -> CGFloat {
        guard let startTime else { return 0 }
        let elapsed = currentTime.timeIntervalSince(startTime)
        let linearProgress = CGFloat(elapsed / 1.5)
        return linearProgress - floor(linearProgress) // Loop between 0-1
    }

    private func startAnimation() {
        animationID = UUID()
        startTime = Date()
    }

    private func resetAnimation() {
        startTime = nil
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Text("Hello, World!")

            Text("Hello, World!")
                .frame(width: 350, height: 500)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)
        }
        .skeleton(isRedacted: true)
    }
    .environment(\.colorScheme, .dark)
}
