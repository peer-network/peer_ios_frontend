//
//  PostDescriptionComment.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import Models
import DesignSystem
import Environment

struct PostDescriptionComment: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router

    @ObservedObject var postVM: PostViewModel
    let isInFeed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button {
                if !isInFeed {
                    dismiss()
                }
                router.navigate(to: .accountDetail(id: postVM.post.owner.id))
            } label: {
                Text(postVM.post.owner.username)
                    .bold()
                    .italic()
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    titleTextView
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(-1)

                    Text(postVM.post.formattedCreatedAtShort)
                        .font(.customFont(weight: .regular, size: .footnoteSmall))
                        .foregroundStyle(Colors.whiteSecondary)
                }

                if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
                    Text(text)
                }

                if isInFeed, postVM.amountComments > 0 {
                    Text("^[\(postVM.amountComments) comment](inflect: true) more...")
                        .foregroundStyle(Colors.whiteSecondary)
                }
            }

            Spacer()
                .frame(width: 35)
        }
        .font(.customFont(weight: .regular, size: .body))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
    }

    private var titleTextView: Text {
        if let attributedTitle = postVM.attributedTitle {
            return Text(attributedTitle)
        } else {
            return Text(postVM.post.title)
        }
    }
}
