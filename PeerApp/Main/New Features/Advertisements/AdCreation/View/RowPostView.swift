//
//  RowPostView.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.09.25.
//

import SwiftUI
import DesignSystem
import Models

struct RowPostView: View {
    let post: Post

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if post.contentType != .text {
                let imageWidth = (getRect().width - 20 * 3) * 0.3
                let imageHeight = imageWidth * 0.77

                Color.red // TODO: Media
                    .frame(width: imageWidth, height: imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay {
                        contentTypeIcon
                    }
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 0) {
                    Text(post.title)
                        .appFont(.bodyBold)
                        .lineLimit(1)

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    PinIndicatorView()
                }

                Text("There’s something about hiking that resets everything.")
                    .appFont(.bodyRegular)
                    .lineLimit(2)
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
            switch post.contentType {
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
}

#Preview {
    RowPostView(post: Post.placeholdersImage(count: 1).first!)
        .padding()
}
