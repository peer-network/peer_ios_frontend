//
//  PostImagesView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import NukeUI
import DesignSystem
import Environment
import Models

struct PostImagesView: View {
    @EnvironmentObject private var quickLook: QuickLook
    @EnvironmentObject private var postVM: PostViewModel

    var body: some View {
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
                        } else if state.isLoading {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                        }
                    }
                    .onTapGesture {
                        tapAction(for: index)
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
    
    private func tapAction(for index: Int) {
        let mediaDataArray = postVM.post.mediaURLs.compactMap { url in
            MediaData(url: url, type: postVM.post.contentType)
        }
        quickLook.prepareFor(selectedMediaAttachment: mediaDataArray[index], mediaAttachments: mediaDataArray)
    }
}
