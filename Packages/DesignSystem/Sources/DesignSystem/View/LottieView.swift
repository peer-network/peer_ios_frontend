//
//  LottieView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 09.04.25.
//

import SwiftUI
import DotLottie

public struct LottieView: View {
    @frozen
    public enum LottieAnimation: String {
        case splashScreenLogo = "SplashScreenLogoAnimation"
        case loading = "LoadingAnimation"
        case confetti = "PartyPopperAnimation"
        case handshake = "HandShake"
    }

    private let name: String
    private let speed: Float
    private let onLoopComplete: (() -> Void)?

    @State private var animation: DotLottieAnimation?
    @State private var dotLottieView: DotLottieView?

    public init(animation: LottieAnimation, speed: Float = 1.0, onLoopComplete: (() -> Void)? = nil) {
        self.name = animation.rawValue
        self.speed = speed
        self.onLoopComplete = onLoopComplete
    }

    public var body: some View {
        Group {
            if let dotLottieView {
                dotLottieView
            } else {
                Color.clear
            }
        }
        .onAppear {
            setupAnimation()
        }
    }

    private func setupAnimation() {
        let config = AnimationConfig(autoplay: true, loop: true, speed: speed)

        let dotLottieAnimation = DotLottieAnimation(fileName: name, config: config)
        let view: DotLottieView = dotLottieAnimation.view()

        let observer = CompletionObserver(onLoopComplete: onLoopComplete)
        view.subscribe(observer: observer)

        animation = dotLottieAnimation
        dotLottieView = view
    }
}

// MARK: - Observer class
private class CompletionObserver: Observer {
    let onLoopComplete: (() -> Void)?

    init(onLoopComplete: (() -> Void)?) {
        self.onLoopComplete = onLoopComplete
    }

    func onComplete() {
    }

    func onFrame(frameNo: Float) {
    }

    func onLoad() {
    }

    func onLoadError() {
    }

    func onLoop(loopCount: UInt32) {
        onLoopComplete?()
    }

    func onPause() {
    }

    func onPlay() {
    }

    func onRender(frameNo: Float) {
    }

    func onStop() {
    }
}
