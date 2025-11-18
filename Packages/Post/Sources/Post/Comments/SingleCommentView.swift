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
                    .font(.custom(.bodyBoldItalic))
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
                    .font(.custom(.smallLabelRegular))
                    .foregroundStyle(Colors.whiteSecondary)
            }

            VStack(spacing: 5) {
                Button {
                    Task {
                        do {
                            try await commentVM.likeComment()
                        } catch {
                            if let error = error as? CommentError {
                                showPopup(text: error.displayMessage)
                            } else {
                                showPopup(
                                    text: error.userFriendlyDescription
                                )
                            }
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
                    .contentShape(.rect)
                }

                Button {
                    dismiss()
                    router.navigate(to: .commentLikes(comment: commentVM.comment))
                } label: {
                    Text("\(commentVM.amountLikes)")
                        .contentShape(.rect)
                }
            }
        }
        .font(.custom(.bodyRegular))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .onFirstAppear {
            commentVM.apiService = apiManager.apiService
        }
        .padding(10)
        .contentShape(Rectangle())
        .contextMenu {
            if !AccountManager.shared.isCurrentUser(id: commentVM.comment.user.id) {
                Button(role: .destructive) {
                    dismiss()
                    SystemPopupManager.shared.presentPopup(.reportComment) {
                        Task {
                            do {
                                try await commentVM.report()
                                showPopup(text: "Comment was reported.")
                            } catch let error as CommentError {
                                showPopup(
                                    text: error.localizedDescription
                                )
                            } catch {
                                showPopup(
                                    text: error.userFriendlyDescription
                                )
                            }
                        }
                    }
                } label: {
                    Label("Report Comment", systemImage: "exclamationmark.circle")
                }
            }
        }
        .padding(-10)
    }
}
