//
//  LazyResizableImage.swift
//  DesignSystem
//
//  Created by Артем Васин on 08.01.25.
//

import Nuke
import NukeUI
import SwiftUI

/// A LazyImage (Nuke) with a geometry reader under the hood in order to use a Resize Processor to optimize performances on lists.
/// This views also allows smooth resizing of the images by debouncing the update of the ImageProcessor.
public struct LazyResizableImage<Content: View>: View {
    public init(url: URL?, @ViewBuilder content: @escaping (LazyImageState, GeometryProxy) -> Content)
    {
        imageURL = url
        self.content = content
    }
    
    let imageURL: URL?
    @State private var resizeProcessor: ImageProcessors.Resize?
    @State private var debouncedTask: Task<Void, Never>?
    @State private var currentSize: CGSize = .zero
    
    @ViewBuilder
    private var content: (LazyImageState, _ proxy: GeometryProxy) -> Content
    
    public var body: some View {
        GeometryReader { proxy in
            LazyImage(url: imageURL) { state in
                content(state, proxy)
            }
            .processors([resizeProcessor == nil ? .resize(size: proxy.size) : resizeProcessor!])
            .onAppear {
                currentSize = proxy.size
                resizeProcessor = .resize(size: proxy.size)
            }
            .onChange(of: currentSize) { newValue in
                debouncedTask?.cancel()
                debouncedTask = Task {
                    do { try await Task.sleep(for: .milliseconds(200)) } catch { return }
                    resizeProcessor = .resize(size: newValue)
                }
            }
            .onChange(of: proxy.size) { newValue in
                if currentSize != newValue {
                    currentSize = newValue
                }
            }
        }
    }
}
