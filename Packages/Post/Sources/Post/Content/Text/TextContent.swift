//
//  TextContent.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem

struct TextContent: View {
    @ObservedObject var postVM: PostViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            titleTextView
                .font(.customFont(weight: .bold, size: .title))
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
                CollapsibleText(text, lineLimit: 8)
                    .font(.customFont(style: .body))
                    .foregroundStyle(Colors.whitePrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                //            VStack(spacing: 0) {
                //                Text(text)
                //                    .font(.customFont(style: .body))
                //                    .foregroundStyle(Colors.whitePrimary)
                //                    .lineLimit(postVM.lineLimit)
                //                    .frame(maxWidth: .infinity, alignment: .leading)
                //                    .ifCondition(postVM.shouldShowCollapseButton) {
                //                        $0.onTapGesture {
                //                            postVM.isCollapsed.toggle()
                //                        }
                //                    }
                //
                //                collapseButton()
                //            }
            }
        }
    }

    private var titleTextView: Text {
        if let attributedTitle = postVM.attributedTitle {
            return Text(attributedTitle)
        } else {
            return Text(postVM.post.title)
        }
    }

    @ViewBuilder
    private func collapseButton() -> some View {
        if postVM.shouldShowCollapseButton {
            Button {
                //                withAnimation {
                postVM.isCollapsed.toggle()
                //                }
            } label: {
                let textToShow: String = postVM.isCollapsed ? "See more..." : "See less..."
                Text(textToShow)
                    .font(.customFont(style: .body))
                    .foregroundStyle(Colors.hashtag)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
    }
}
