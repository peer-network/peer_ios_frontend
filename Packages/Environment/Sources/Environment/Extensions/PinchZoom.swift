//
//  PinchZoom.swift
//  Environment
//
//  Created by Artem Vasin on 20.08.25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func pinchZoom(_ dimsBackground: Bool = true, snapshot: Bool = true) -> some View {
        PinchZoomHelper(dimsBackground: dimsBackground, snapshot: snapshot) { self }
    }
}

/// A root wrapper that renders a zoomed copy of the active view above everything else.
public struct ZoomContainer<Content: View>: View {
    private let content: Content

    // MUST be @State so the instance survives view re-renders
    @State private var containerData = ZoomContainerData()

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            content
                .environment(containerData)

            if let view = containerData.zoomingView {
                if containerData.dimsBackground {
                    Color.black
                        .opacity(containerData.backgroundOpacity)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                // Force the zoomed copy to keep the ORIGINAL size
                view
                    .frame(width: containerData.viewRect.width,
                           height: containerData.viewRect.height)
                    .scaleEffect(containerData.zoom, anchor: containerData.zoomAnchor)
                    .position(x: containerData.viewRect.midX,
                              y: containerData.viewRect.midY)
                    .offset(containerData.dragOffset)
                    .ignoresSafeArea()
                    .allowsHitTesting(false) // don't steal touches
            }
        }
        // Coordinate space so frame math is consistent everywhere
        .coordinateSpace(name: ZoomContainerData.coordinateSpaceName)
    }
}

/// Shared data between the container and pinch views.
@MainActor
@Observable
fileprivate final class ZoomContainerData {
    static let coordinateSpaceName: String = "ZoomContainerSpace"

    var zoomingView: AnyView?
    var viewRect: CGRect = .zero
    var dimsBackground: Bool = false

    var zoom: CGFloat = 1
    var dragOffset: CGSize = .zero
    var zoomAnchor: UnitPoint = .center

    var isResetting: Bool = false

    var backgroundOpacity: Double {
        // clamp 0...0.7
        let value = (zoom - 1) * 0.45
        return min(0.7, max(0, value))
    }
}

/// Helper that lives on the zoomable view and talks to the container.
fileprivate struct PinchZoomHelper<Content: View>: View {
    @Environment(ZoomContainerData.self) private var containerData

    let dimsBackground: Bool
    let snapshot: Bool
    @ViewBuilder var content: Content

    @State private var config: ZoomConfig = .init()

    var body: some View {
        content
            .opacity(config.hidesSourceView ? 0 : 1)
            .animation(nil, value: config.hidesSourceView)
            .overlay(GestureOverlay(config: $config))
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: config.isGestureActive) { _, isActive in
                            guard !containerData.isResetting else { return }

                            if isActive {
                                let rect = geometry.frame(in: .named(ZoomContainerData.coordinateSpaceName))
                                containerData.viewRect = rect
                                containerData.zoomAnchor = config.zoomAnchor
                                containerData.dimsBackground = dimsBackground

                                if snapshot, rect.width > 1, rect.height > 1,
                                   let img = renderSnapshot(size: rect.size) {
                                    // zoom exactly what user saw (cropped/masked)
                                    containerData.zoomingView = AnyView(
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: rect.width, height: rect.height)
                                            .clipped()
                                    )
                                } else {
                                    // Fallback: re-host view (can relayout)
                                    containerData.zoomingView = AnyView(content)
                                }

                                config.hidesSourceView = true
                            } else {
                                containerData.isResetting = true
                                withAnimation(.spring(response: 0.20, dampingFraction: 0.86)) {
                                    containerData.dragOffset = .zero
                                    containerData.zoom = 1
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                    config = .init()
                                    containerData.zoomingView = nil
                                    containerData.isResetting = false
                                }
                            }
                        }
                        .onChange(of: config.zoom) { _, newZoom in
                            guard config.isGestureActive, !containerData.isResetting else { return }
                            containerData.zoom = newZoom
                        }
                        .onChange(of: config.dragOffset) { _, newOffset in
                            guard config.isGestureActive, !containerData.isResetting else { return }
                            containerData.dragOffset = newOffset
                        }
                }
            }
    }

    @MainActor
    private func renderSnapshot(size: CGSize) -> UIImage? {
        // Render the *already modified* content at the exact on-screen size
        let renderer = ImageRenderer(
            content: content
                .frame(width: size.width, height: size.height)
                .clipped()
        )
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = false
        return renderer.uiImage
    }
}


/// UIKit gesture layer. We keep it UIKit so pinch+pan feels great.
fileprivate struct GestureOverlay: UIViewRepresentable {
    @Binding var config: ZoomConfig

    func makeCoordinator() -> Coordinator { Coordinator(config: $config) }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = true

        let pan = UIPanGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handlePan(_:)))
        pan.name = "PINCHPANGESTURE"
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        pan.cancelsTouchesInView = true
        pan.delaysTouchesBegan = true
        pan.delegate = context.coordinator
        view.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: context.coordinator,
                                             action: #selector(Coordinator.handlePinch(_:)))
        pinch.name = "PINCHZOOMGESTURE"
        pinch.cancelsTouchesInView = true
        pinch.delaysTouchesBegan = true
        pinch.delegate = context.coordinator
        view.addGestureRecognizer(pinch)

        return view
    }


    func updateUIView(_ uiView: UIView, context: Context) {}

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @Binding var config: ZoomConfig

        private var isPinching = false
        private var isPanning = false

        init(config: Binding<ZoomConfig>) { self._config = config }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began, .changed:
                isPanning = true
                let t = gesture.translation(in: gesture.view)
                config.dragOffset = .init(width: t.x, height: t.y)
            default:
                isPanning = false
            }
            config.isGestureActive = isPinching || isPanning
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                isPinching = true
                if let view = gesture.view, view.bounds.width > 0, view.bounds.height > 0 {
                    let p = gesture.location(in: view)
                    config.zoomAnchor = .init(x: p.x / view.bounds.width,
                                              y: p.y / view.bounds.height)
                }
                fallthrough
            case .changed:
                isPinching = true
                config.zoom = max(gesture.scale, 1)
            default:
                isPinching = false
            }
            config.isGestureActive = isPinching || isPanning
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            let a = gestureRecognizer.name
            let b = otherGestureRecognizer.name

            return (a == "PINCHPANGESTURE" && b == "PINCHZOOMGESTURE")
                || (a == "PINCHZOOMGESTURE" && b == "PINCHPANGESTURE")
        }
    }

}

fileprivate struct ZoomConfig: Equatable {
    var isGestureActive: Bool = false
    var zoom: CGFloat = 1
    var zoomAnchor: UnitPoint = .center
    var dragOffset: CGSize = .zero
    var hidesSourceView: Bool = false
}
