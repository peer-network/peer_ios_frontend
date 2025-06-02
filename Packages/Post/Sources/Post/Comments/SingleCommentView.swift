//
//  SingleCommentView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment

struct SingleCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var router: Router

    @StateObject private var commentVM: SingleCommentViewModel

    init(comment: Comment) {
        _commentVM = .init(wrappedValue: .init(comment: comment))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button {
                dismiss()
                router.navigate(to: .accountDetail(id: commentVM.comment.user.id))
            } label: {
                Text(commentVM.comment.user.username)
                    .bold()
                    .italic()
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if let attributedText = commentVM.attributedContent {
                        Text(attributedText)
                    } else {
                        Text(commentVM.comment.content)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(commentVM.comment.formattedCreatedAt)
                    .font(.customFont(weight: .regular, style: .caption1))
                    .foregroundStyle(Colors.whiteSecondary)
            }

            VStack(spacing: 5) {
                Button {
                    Task {
                        do {
                            try await commentVM.likeComment()
                        } catch {
                            showPopup(text: "Failed to perform the action. Please try again.")
                        }
                    }
                } label: {
                    Group {
                        if commentVM.isLiked {
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

                Text("\(commentVM.amountLikes)")
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .onFirstAppear {
            commentVM.apiService = apiManager.apiService
        }
    }
}
