//
//  PinchZoom.swift
//  Environment
//
//  Created by Artem Vasin on 20.08.25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func pinchZoom(_ dimsBackground: Bool = true) -> some View {
        PinchZoomHelper(dimsBackground: dimsBackground) {
            self
        }
    }
}

/// Zoom Container View
/// Where the Zooming View will be displayed and zoomed
public struct ZoomContainer<Content: View>: View {
    private var content: Content
    private var containerData = ZoomContainerData()

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    public var body: some View {
        GeometryReader { _ in
            content
                .environment(containerData)

            ZStack(alignment: .topLeading) {
                if let view = containerData.zoomingView {
                    Group {
                        if containerData.dimsBackground {
                            Color.black
                                .opacity((containerData.zoom - 1) * 0.5)
                        }

                        view
                            .scaleEffect(containerData.zoom, anchor: containerData.zoomAnchor)
                            .offset(containerData.dragOffset)
                        /// View Position
                            .offset(x: containerData.viewRect.minX, y: containerData.viewRect.minY)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

/// Observable Class to share data between Container and it's Views inside it
@Observable
fileprivate class ZoomContainerData {
    var zoomingView: AnyView?
    var viewRect: CGRect = .zero
    var dimsBackground: Bool = false

    // Use private storage with computed properties to reduce unnecessary updates
    private var _zoom: CGFloat = 1
    private var _dragOffset: CGSize = .zero

    var zoom: CGFloat {
        get { _zoom }
        set {
            // Only update if significantly different to reduce view updates
            if abs(newValue - _zoom) > 0.001 {
                _zoom = newValue
            }
        }
    }

    var dragOffset: CGSize {
        get { _dragOffset }
        set {
            // Only update if significantly different
            if abs(newValue.width - _dragOffset.width) > 0.1 ||
               abs(newValue.height - _dragOffset.height) > 0.1 {
                _dragOffset = newValue
            }
        }
    }

    var zoomAnchor: UnitPoint = .center
    var isResetting: Bool = false

    // Computed property for background opacity to avoid constant Rectangle updates
    var backgroundOpacity: Double {
        min(0.7, max(0, (zoom - 1) * 0.4))
    }
}


/// Helper View
fileprivate struct PinchZoomHelper<Content: View>: View {
    @Environment(ZoomContainerData.self) private var containerData

    var dimsBackground: Bool
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
                        .onChange(of: config.isGestureActive) { oldValue, newValue in
                            guard !containerData.isResetting else { return }
                            if newValue {
                                /// Showing View on Zoom Container
                                let rect = geometry.frame(in: .global)
                                containerData.viewRect = rect
                                containerData.zoomAnchor = config.zoomAnchor
                                containerData.dimsBackground = dimsBackground
                                containerData.zoomingView = .init(erasing: content)
                                /// Hiding Source View
                                config.hidesSourceView = true
                            } else {
                                /// Resetting to it's Intial Position With Animation
                                containerData.isResetting = true
                                withAnimation(.spring(response: 0.18, dampingFraction: 0.85), completionCriteria: .logicallyComplete) {
                                    containerData.dragOffset = .zero
                                    containerData.zoom = 1
                                } completion: {
                                    /// Resetting Config
                                    config = .init()
                                    /// Removing View From Container Layer
                                    containerData.zoomingView = nil
                                    containerData.isResetting = false
                                }
                            }
                        }
                        .onChange(of: config) { oldValue, newValue in
                            if config.isGestureActive && !containerData.isResetting {
                                /// Updating View's Position and Scale in Zoom Container
                                containerData.zoom = config.zoom
                                containerData.dragOffset = config.dragOffset
                            }
                        }
                }
            }
    }
}

/// UIKit Gestures Overlay
fileprivate struct GestureOverlay: UIViewRepresentable {
    @Binding var config: ZoomConfig
    func makeCoordinator() -> Coordinator {
        Coordinator(config: $config)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        /// Pan Gesture
        let panGesture = UIPanGestureRecognizer()
        panGesture.name = "PINCHPANGESTURE"
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.addTarget(context.coordinator, action: #selector(Coordinator.panGesture(gesture:)))
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(panGesture)

        /// Pinch Gesture
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.name = "PINCHZOOMGESTURE"
        pinchGesture.addTarget(context.coordinator, action: #selector(Coordinator.pinchGesture(gesture:)))
        pinchGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {  }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @Binding var config: ZoomConfig

        init(config: Binding<ZoomConfig>) {
            self._config = config
        }

        @objc
        func panGesture(gesture: UIPanGestureRecognizer) {
            if gesture.state == .began || gesture.state == .changed {
                let translation = gesture.translation(in: gesture.view)
                config.dragOffset = .init(width: translation.x, height: translation.y)
                config.isGestureActive = true
            } else {
                config.isGestureActive = false
            }
        }

        @objc
        func pinchGesture(gesture: UIPinchGestureRecognizer) {
            if gesture.state == .began {
                let location = gesture.location(in: gesture.view)
                if let bounds = gesture.view?.bounds {
                    config.zoomAnchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
                }
            }

            if gesture.state == .began || gesture.state == .changed {
                let scale = max(gesture.scale, 1)
                config.zoom = scale
                config.isGestureActive = true
            } else {
                config.isGestureActive = false
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer.name == "PINCHPANGESTURE" && otherGestureRecognizer.name == "PINCHZOOMGESTURE" {
                return true
            }

            return false
        }
    }
}

/// Config
fileprivate struct ZoomConfig: Equatable {
    var isGestureActive: Bool = false
    var zoom: CGFloat = 1
    var zoomAnchor: UnitPoint = .center
    var dragOffset: CGSize = .zero
    var hidesSourceView: Bool = false
}
