//
//  RowAdPostView.swift
//  Post
//
//  Created by Artem Vasin on 03.11.25.
//

import SwiftUI
import DesignSystem
import Models
import NukeUI

public struct RowAdPostView: View {
    @StateObject private var postVM: PostViewModel

    public init(post: Post) {
        _postVM = .init(wrappedValue: .init(post: post))
    }

    private var mediaURL: URL? {
        if postVM.post.contentType == .image {
            return postVM.post.mediaURLs.first!
        } else {
            return postVM.post.coverURL ?? nil
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if postVM.post.contentType != .text {
                let imageWidth = (getRect().width - 20 * 3) * 0.3
                let imageHeight = imageWidth * 0.77

                LazyImage(url: mediaURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: imageWidth,
                                height: imageHeight
                            )
                            .clipShape(Rectangle())
                    } else {
                        Colors.blackDark
                    }
                }
                .frame(width: imageWidth, height: imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay {
                    contentTypeIcon
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 0) {
                    Text(postVM.post.title)
                        .appFont(.bodyBold)
                        .lineLimit(1)

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    PinIndicatorViewSmall()
                }

                if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
                    Text(text)
                        .appFont(.bodyRegular)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var contentTypeIcon: some View {
        Group {
            switch postVM.post.contentType {
                case .text:
                    Icons.a
                        .iconSize(height: 20)
                case .image:
                    Icons.camera
                        .iconSize(height: 20)
                case .video:
                    Icons.play
                        .iconSize(height: 20)
                case .audio:
                    Icons.musicBars
                        .iconSize(height: 20)
            }
        }
    }

    private struct PinIndicatorViewSmall: View {
        var body: some View {
            Icons.pin
                .iconSize(height: 15)
                .foregroundStyle(Colors.whitePrimary)
                .padding(7.5)
                .background {
                    Circle()
                        .foregroundStyle(Colors.version)
                }
        }
    }
}
