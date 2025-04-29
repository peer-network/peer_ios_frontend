//
//  PostTextView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import DesignSystem
import Environment

struct PostTextView: View {
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @EnvironmentObject private var postVM: PostViewModel
    
    var body: some View {
        Text(postVM.post.title)
            .font(.customFont(weight: .bold, size: .title))
            .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
            .frame(maxWidth: .infinity, alignment: .leading)

        if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
            VStack(spacing: 0) {
                Text(text)
                    .font(.customFont(style: .body))
                    .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
                    .lineLimit(postVM.lineLimit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ifCondition(postVM.shouldShowCollapseButton) {
                        $0.onTapGesture {
                            postVM.isCollapsed.toggle()
                        }
                    }

                collapseButton()
            }
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

#Preview {
    PostTextView()
        .environmentObject(PostViewModel(post: .placeholderText()))
}
