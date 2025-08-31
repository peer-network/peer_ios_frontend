//
//  ImageCropperView.swift
//  PostCreation
//
//  Created by Artem Vasin on 26.08.25.
//

import SwiftUI
import DesignSystem
import UIKit

/// A transparent UIView that relays UIPinch (incremental) + 2-finger UIPan (delta).
private struct PinchPanRelay: UIViewRepresentable {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onPinchChanged: ((CGFloat, CGPoint) -> Void)?   // kDelta, centerInView
        var onPanChanged: ((CGPoint) -> Void)?              // delta translation
        var onGestureEnded: (() -> Void)?

        private var lastPan: CGPoint = .zero

        @objc func handlePinch(_ gr: UIPinchGestureRecognizer) {
            guard let view = gr.view else { return }
            let center = gr.location(in: view)
            switch gr.state {
            case .changed:
                let kDelta = gr.scale                    // incremental since last reset
                onPinchChanged?(kDelta, center)
                gr.scale = 1.0                          // 🔑 make subsequent updates incremental
            case .ended, .cancelled, .failed:
                onGestureEnded?()
            default: break
            }
        }

        @objc func handlePan(_ gr: UIPanGestureRecognizer) {
            guard let view = gr.view else { return }
            switch gr.state {
            case .began:
                lastPan = .zero
            case .changed:
                let t = gr.translation(in: view)
                let delta = CGPoint(x: t.x - lastPan.x, y: t.y - lastPan.y)
                lastPan = t
                onPanChanged?(delta)
            case .ended, .cancelled, .failed:
                onGestureEnded?()
            default: break
            }
        }

        func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
        func gestureRecognizerShouldBegin(_ g: UIGestureRecognizer) -> Bool { true }
    }

    var onPinchChanged: (CGFloat, CGPoint) -> Void
    var onPanChanged: (CGPoint) -> Void
    var onEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        let c = Coordinator()
        c.onPinchChanged = onPinchChanged
        c.onPanChanged   = onPanChanged
        c.onGestureEnded = onEnded
        return c
    }

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = true
        v.isMultipleTouchEnabled = true

        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        pinch.cancelsTouchesInView = true
        pinch.delegate = context.coordinator

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        pan.cancelsTouchesInView = true
        pan.delegate = context.coordinator

        v.addGestureRecognizer(pinch)
        v.addGestureRecognizer(pan)
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}



// MARK: - Cropper

struct InlineCropView: View {
    // Inputs
    private let baseImage: UIImage         // normalized to .up
    let aspectRatio: PostImagesAspectRatio
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void

    // Transform (relative to crop frame center, in POINTS)
    @State private var offset: CGSize = .zero    // translation
    @State private var scale: CGFloat = 1.0      // absolute scale

    // Gesture baselines
    @State private var startScale: CGFloat = 1.0
    @State private var startOffset: CGSize = .zero
    @State private var isPinching: Bool = false

    // Config
    private let overscroll: CGFloat = 220

    // Init to normalize orientation once
    init(image: UIImage, aspectRatio: PostImagesAspectRatio, onCrop: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.baseImage = image.normalizedUp()
        self.aspectRatio = aspectRatio
        self.onCrop = onCrop
        self.onCancel = onCancel
    }

    // Derived sizes
    private var cropWidth: CGFloat  { aspectRatio.imageFrameWidth(for: UIScreen.main.bounds.width) }
    private var cropHeight: CGFloat { aspectRatio.imageFrameHeight(for: UIScreen.main.bounds.width) }

    private var imgPtSize: CGSize { baseImage.size }
    private var cgImage: CGImage? { baseImage.cgImage }
    private var imgPxSize: CGSize {
        guard let cg = cgImage else { return .zero }
        return CGSize(width: cg.width, height: cg.height)
    }

    private var pxPerPt: CGFloat {
        // Use a single factor to remove x/y rounding drift that was causing 1230x1231.
        // iOS uses square pixels; width factor is sufficient.
        max(imgPxSize.width / imgPtSize.width, imgPxSize.height / imgPtSize.height)
    }

    private var minCoverScale: CGFloat {
        max(cropWidth / imgPtSize.width, cropHeight / imgPtSize.height)
    }
    private var maxScale: CGFloat { minCoverScale * 8 }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Image(uiImage: baseImage)
                    .resizable()
                    .frame(width: imgPtSize.width * scale, height: imgPtSize.height * scale)
                    .offset(offset)
                    .frame(width: cropWidth, height: cropHeight)
                    .clipped()

                gridView()
                    .allowsHitTesting(false)

                PinchPanRelay(
                    onPinchChanged: { kDelta, center in
                        // target scale with strict clamp (no rubber band during pinch)
                        let targetScale = min(max(scale * kDelta, minCoverScale), maxScale)

                        // incremental factor actually applied
                        let effK = targetScale / scale
                        guard effK.isFinite && effK > 0 else { return }

                        // focus point in crop coords (origin at crop center)
                        let focus = CGPoint(x: center.x - cropWidth/2, y: center.y - cropHeight/2)

                        // incremental transform: t' = k * t + (1 - k) * F
                        let proposed = CGSize(
                            width:  effK * offset.width  + (1 - effK) * focus.x,
                            height: effK * offset.height + (1 - effK) * focus.y
                        )

                        // strict clamp during pinch to avoid any release jump
                        scale  = targetScale
                        offset = clampOffset(proposed, scale: targetScale, loose: false)
                    },
                    onPanChanged: { delta in
                        // true 2-finger pan; strict clamp as well
                        let tentative = CGSize(width: offset.width + delta.x, height: offset.height + delta.y)
                        offset = clampOffset(tentative, scale: scale, loose: false)
                    },
                    onEnded: {
                        // nothing to fix for scale; just ensure we're inside strict bounds
                        withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) {
                            offset = clampOffset(offset, scale: scale, loose: false)
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)

            }
            .frame(width: cropWidth, height: cropHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .contentShape(Rectangle())
            // High-priority so it wins over ancestor ScrollView
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        guard !isPinching else { return } // don't fight the pinch
                        if value.startLocation == value.location { startOffset = offset }
                        let tentative = CGSize(
                            width: startOffset.width + value.translation.width,
                            height: startOffset.height + value.translation.height
                        )
                        offset = clampOffset(tentative, scale: scale, loose: true)
                    }
                    .onEnded { _ in
                        guard !isPinching else { return }
                        withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) {
                            offset = clampOffset(offset, scale: scale, loose: false)
                        }
                        startOffset = offset
                    }
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Colors.whitePrimary, style: .init(lineWidth: 3, lineCap: .round, dash: [6, 10]))
                    .allowsHitTesting(false)
            }

            HStack(spacing: 20) {
                StateButton(config: .init(buttonSize: .large, buttonType: .teritary, title: "Cancel"), action: onCancel)
                StateButton(config: .init(buttonSize: .large, buttonType: .primary, title: "Save"), action: cropImage)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            scale = minCoverScale
            offset = .zero
            startScale = scale
            startOffset = offset
        }
        .scrollDisabled(true)
    }

    // MARK: - Clamping

    /// Strict clamp for final state (must cover frame).
    private func clampScaleFinal(_ s: CGFloat) -> CGFloat {
        min(max(s, minCoverScale), maxScale)
    }

    /// Offset clamp; loose=true allows rubber-band.
    private func clampOffset(_ candidate: CGSize, scale s: CGFloat, loose: Bool) -> CGSize {
        let dispW = imgPtSize.width * s
        let dispH = imgPtSize.height * s

        let xStrict = max(0, (dispW - cropWidth) / 2)
        let yStrict = max(0, (dispH - cropHeight) / 2)

        let xLoose = xStrict + overscroll
        let yLoose = yStrict + overscroll

        let bx = loose ? xLoose : xStrict
        let by = loose ? yLoose : yStrict

        return CGSize(
            width: min(bx, max(-bx, candidate.width)),
            height: min(by, max(-by, candidate.height))
        )
    }

    // MARK: - Cropping (pixel-accurate & exact aspect ratio)

    private func cropImage() {
        guard let cg = cgImage else { return }

        // crop center in original pixels (map crop-space origin to pixels)
        func centerToPixels() -> CGPoint {
            // p = (0,0) in crop space (center)
            // rPt (image points relative to its center) = (p - offset)/scale = (-offset)/scale
            let rPt = CGPoint(x: -offset.width / scale, y: -offset.height / scale)
            return CGPoint(
                x: imgPxSize.width/2  + rPt.x * pxPerPt,
                y: imgPxSize.height/2 + rPt.y * pxPerPt
            )
        }

        // Desired size in pixels at current zoom (include `scale` so the crop matches preview)
        // Start from geometry and enforce ratio explicitly to avoid 1-px drift.
        let baseW = (cropWidth  / scale) * pxPerPt
        let baseH = (cropHeight / scale) * pxPerPt

        let desiredW: Int
        let desiredH: Int
        switch aspectRatio {
        case .square:
            let w = Int(round(baseW))
            desiredW = w
            desiredH = w
        case .vertical: // 4:5 (width:height)
            // choose W close to baseW, then compute H from ratio so it's exact
            let w = Int(round(baseW))
            desiredW = max(1, w)
            desiredH = max(1, Int(round(Double(desiredW) * 5.0 / 4.0)))
        }

        var cx = centerToPixels().x
        var cy = centerToPixels().y

        // Build centered rect with exact integer size
        var x = CGFloat(desiredW) * -0.5 + cx
        var y = CGFloat(desiredH) * -0.5 + cy

        // Round origin to pixels (do not change size, so aspect ratio stays exact)
        x = round(x)
        y = round(y)

        // Clamp into image bounds by shifting only (preserve size & ratio)
        let maxX = imgPxSize.width  - CGFloat(desiredW)
        let maxY = imgPxSize.height - CGFloat(desiredH)
        x = min(max(0, x), maxX)
        y = min(max(0, y), maxY)

        let rect = CGRect(x: x, y: y, width: CGFloat(desiredW), height: CGFloat(desiredH))
        guard rect.width >= 1, rect.height >= 1, let cropped = cg.cropping(to: rect) else { return }

        let out = UIImage(cgImage: cropped, scale: baseImage.scale, orientation: .up)
        onCrop(out)
    }

    // MARK: - Grid overlay

    @ViewBuilder
    private func gridView() -> some View {
        ZStack {
            HStack {
                Spacer(); Rectangle().foregroundStyle(Colors.whiteSecondary).frame(width: 1)
                Spacer(); Rectangle().foregroundStyle(Colors.whiteSecondary).frame(width: 1)
                Spacer()
            }
            VStack {
                Spacer(); Rectangle().foregroundStyle(Colors.whiteSecondary).frame(height: 1)
                Spacer(); Rectangle().foregroundStyle(Colors.whiteSecondary).frame(height: 1)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
