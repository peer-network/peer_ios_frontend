//
//  SingleCommentView.swift
//  FeedNew
//
//  Created by Артем Васин on 06.02.25.
//

import SwiftUI
import Models
import DesignSystem
import Environment

struct PostDescriptionComment: View {
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var postVM: PostViewModel

    let isInFeed: Bool

//    var tags: [String] {
//        postVM.post.tags.map { "#\($0)"}
//    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button {
                router.navigate(to: .accountDetail(id: postVM.post.owner.id))
            } label: {
                Text(postVM.post.owner.username)
                    .bold()
                    .italic()
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    Text(postVM.post.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(-1)

                    Text(postVM.post.formattedCreatedAtShort)
                        .font(.customFont(weight: .regular, size: .footnoteSmall))
                        .foregroundStyle(isBackgroundWhite ? Colors.inactiveDark : Colors.whiteSecondary)
                }

                if !postVM.post.mediaDescription.isEmpty {
                    Text(postVM.attributedString)
                }

//                if !postVM.post.tags.isEmpty {
//                    Text(tags.joined(separator: " "))
//                        .foregroundStyle(Colors.hashtag)
//                }

                if isInFeed, postVM.post.amountComments > 0 {
                    Text("^[\(postVM.post.amountComments) comment](inflect: true) more...")
                        .foregroundStyle(Colors.whiteSecondary)
                }
            }
            
            Spacer()
                .frame(width: 35)
        }
        .font(.customFont(weight: .regular, size: .body))
        .multilineTextAlignment(.leading)
        .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
    }
}

struct SingleCommentView: View {
    @EnvironmentObject private var router: Router

    @EnvironmentObject private var viewModel: CommentsViewModel

    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button {
                router.navigate(to: .accountDetail(id: comment.user.id))
            } label: {
                Text(comment.user.username)
                    .bold()
                    .italic()
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(comment.content)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(comment.formattedCreatedAt)
                    .font(.customFont(weight: .regular, style: .caption1))
                    .foregroundStyle(isBackgroundWhite ? Colors.inactiveDark : Colors.whiteSecondary)
            }

            VStack(spacing: 5) {
                Button {
                    Task {
                        do {
                            try await viewModel.likeComment(comment: comment)
                        } catch {
                            showPopup(text: "Failed to perform the action. Please try again.")
                        }
                    }
                } label: {
                    Group {
                        if comment.isLiked {
                            Icons.heartFill
                                .iconSize(height: 15)
                                .foregroundStyle(Colors.redAccent)
                        } else {
                            Icons.heart
                                .iconSize(height: 15)
                        }
                    }
                    .clipShape(Rectangle())
                }

                Text("\(comment.amountLikes)")
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .multilineTextAlignment(.leading)
        .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
    }
}

#Preview {
    GeometryReader { proxy in
        let width = proxy.size.width
        VStack {
            VStack {
                PostDescriptionComment(isInFeed: true)
                SingleCommentView(comment: .placeholder())
            }
            .padding()
            .environment(\.isBackgroundWhite, false)

            VStack {
                PostDescriptionComment(isInFeed: false)
                SingleCommentView(comment: .placeholder())
            }
            .padding()
            .background(Color.black)
            .environment(\.isBackgroundWhite, true)
        }
    }
}
