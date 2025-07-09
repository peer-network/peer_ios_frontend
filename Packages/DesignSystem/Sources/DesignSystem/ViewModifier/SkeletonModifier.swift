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

    var rotation: Double {
        return 0
    }

    var animation: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
    }

    @State private var isAnimating: Bool = false
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .redacted(reason: isRedacted ? .placeholder : [])
            .overlay {
                if isRedacted {
                    GeometryReader {
                        let size = $0.size
                        let skeletonWidth = size.width / 2
                        let blurRadius = max(skeletonWidth / 2, 30)
                        let blurDiameter = blurRadius * 2
                        let minX = -(skeletonWidth + blurDiameter)
                        let maxX = size.width + skeletonWidth + blurDiameter

                        Rectangle()
                            .fill(scheme == .dark ? .white : .black)
                            .frame(width: skeletonWidth, height: size.height * 2)
                            .frame(height: size.height)
                            .blur(radius: blurRadius)
                            .rotationEffect(.init(degrees: rotation))
                            .offset(x: isAnimating ? maxX : minX)
                    }
                    .mask {
                        content
                            .redacted(reason: .placeholder)
                    }
                    .blendMode(.softLight)
                    .task { @MainActor in
                        guard !isAnimating else { return }
                        withAnimation(animation) {
                            isAnimating = true
                        }
                    }
                    .onDisappear {
                        isAnimating = false
                    }
                    .transaction {
                        if $0.animation != animation {
                            $0.animation = .none
                        }
                    }
                }
            }
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
