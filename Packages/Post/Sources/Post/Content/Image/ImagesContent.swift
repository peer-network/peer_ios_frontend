//
//  ImagesContent.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import NukeUI
import DesignSystem
import Environment
import Models

struct ImagesContent: View {
    @Environment(\.redactionReasons) private var reasons

    @EnvironmentObject private var quickLook: QuickLook

    @ObservedObject var postVM: PostViewModel

    var body: some View {
        if reasons.contains(.placeholder) {
            Colors.imageLoadingPlaceholder
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.width
                )
        } else {
            if !postVM.post.mediaURLs.isEmpty {
                TabView {
                    ForEach(postVM.post.mediaURLs.indices, id: \.self) { index in
                        LazyImage(url: postVM.post.mediaURLs[index]) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: UIScreen.main.bounds.width,
                                        height: UIScreen.main.bounds.width
                                    )
                                    .clipShape(Rectangle())
                                    .onTapGesture {
                                        tapAction(for: index)
                                    }
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.large)
//                                Colors.imageLoadingPlaceholder
//                                    .skeleton(isRedacted: true)
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.width
                )
                .clipped()
                .contentShape(Rectangle())
            }
        }
    }

    private func tapAction(for index: Int) {
        let mediaDataArray = postVM.post.mediaURLs.compactMap { url in
            MediaData(url: url, type: postVM.post.contentType)
        }
        quickLook.prepareFor(selectedMediaAttachment: mediaDataArray[index], mediaAttachments: mediaDataArray)
    }
}
