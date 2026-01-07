//
//  ImagesContent.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import NukeUI
import Nuke
import DesignSystem
import Environment
import Models

public struct ImagesContent: View {
    @Environment(\.redactionReasons) private var reasons
    @EnvironmentObject private var quickLook: QuickLook

    @ObservedObject var postVM: PostViewModel
    private let forcedAspectRatio: CGFloat?

    public init(postVM: PostViewModel, aspectRatio: CGFloat? = nil) {
        self.postVM = postVM
        self.forcedAspectRatio = aspectRatio
    }

    private var aspectRatio: CGFloat {
        forcedAspectRatio ?? postVM.post.media.first?.aspectRatio ?? 1
    }

    public var body: some View {
        Group {
            if reasons.contains(.placeholder) || postVM.post.mediaURLs.isEmpty {
                Colors.imageLoadingPlaceholder
            } else {
                TabView {
                    ForEach(postVM.post.mediaURLs, id: \.self) { url in
                        LazyImage(url: url) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                    .pinchZoom()
                            } else {
                                Colors.imageLoadingPlaceholder
                                    .overlay {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .controlSize(.large)
                                    }
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(aspectRatio, contentMode: .fit)
        .background(Colors.imageLoadingPlaceholder)
        .clipped()
        .contentShape(Rectangle())
    }
}
