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
//            .font(.customFont(weight: .bold, size: .footnote))
            .font(.customFont(weight: .bold, size: .title))
            .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
            .frame(maxWidth: .infinity, alignment: .leading)

        if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
            VStack(spacing: 0) {
                //            HashtagTextView(
                //                inputString: postVM.post.mediaDescription,
                //                font: UIFont(name: FontType.poppins.name + FontWeight.regular.name, size: 14)!,
                //                textColor: UIColor(Colors.textActive),
                //                lineLimit: postVM.lineLimit,
                //                alignment: .left,
                //                onHashtagTap: { hashtag in
                //                    print("Hashtag tapped: \(hashtag)")
                //                }
                //            )
                //            .frame(maxWidth: .infinity, alignment: .leading)

                Text(text)
                //                .font(.customFont(weight: .regular, size: .footnote))
                    .font(.customFont(style: .body))
                    .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
                    .lineLimit(postVM.lineLimit)
                    .frame(maxWidth: .infinity, alignment: .leading)

                collapseButton()
            }
        }
    }
    
    @ViewBuilder
    private func collapseButton() -> some View {
        if postVM.lineLimit != nil {
            Button {
                postVM.isCollapsed.toggle()
            } label: {
                Text("See more...")
                    .font(.customFont(weight: .regular, size: .footnote))
                    .foregroundStyle(Colors.whiteSecondary)
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
