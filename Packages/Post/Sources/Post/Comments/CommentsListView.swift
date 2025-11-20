//
//  CommentsListView.swift
//  Post
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment
import Analytics

struct CommentsListView: View {
    @ObservedObject var viewModel: PostViewModel

    public init(viewModel: PostViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.bottom, 10)

            Text("Comments")
                .font(.customFont(weight: .regular, size: .body))
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
                .padding(.leading, 10)

            ScrollView {
                LazyVStack(spacing: 10) {
                    PostDescriptionComment(postVM: viewModel, isInFeed: false)
                        .padding(.horizontal, 10)

                    switch viewModel.state {
                        case .loading:
                            ForEach(Comment.placeholders(count: 15)) { comment in
                                SingleCommentView(comment: comment)
                                    .contentShape(Rectangle())
                                    .allowsHitTesting(false)
                                    .skeleton(isRedacted: true)
                            }
                            .padding(.horizontal, 10)
                        case .display:
                            if viewModel.comments.isEmpty {
                                Text("No comments yet...")
                                    .padding(.top, 20)
                            } else {
                                ForEach(viewModel.comments) { comment in
                                    SingleCommentView(comment: comment)
                                        .padding(.horizontal, 10)
                                }

                                if viewModel.hasMoreComments {
                                    NextPageView {
                                        viewModel.fetchComments(reset: false)
                                    }
                                } else {
                                    EmptyView()
                                }
                            }
                        case .error(let error):
                            ErrorView(title: "Error", description: error.userFriendlyDescription) {
                                viewModel.fetchComments(reset: true)
                            }
                            .padding(20)
                    }
                }
            }
            .scrollDismissesKeyboard(.never)
            .scrollIndicators(.hidden)
            .padding(.bottom, 5)
            .padding(.top, 5)

            if !viewModel.showIllegalBlur {
                HStack(alignment: .center, spacing: 10) {
                    if let user = AccountManager.shared.user {
                        ProfileAvatarView(url: user.imageURL, name: user.username, config: .comment, ignoreCache: true)
                    }

                    commentTextField
                }
                .padding(.top, 5)
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 10)
        .onFirstAppear {
            viewModel.fetchComments(reset: true)
        }
        .trackScreen(AppScreen.commentsSheet)
    }

    private var commentTextField: some View {
        HStack(alignment: .center, spacing: 10) {
            TextField(text: $viewModel.commentText, axis: .vertical) {
                Text("Write a comment...")
                    .foregroundStyle(Colors.textSuggestions)
            }
            .lineLimit(5)
            .foregroundStyle(Color.black)
            .font(.customFont(weight: .regular, size: .footnote))
            .frame(maxWidth: .infinity, alignment: .leading)

            sendCommentButton
        }
        .padding(.leading, 10)
        .padding(.trailing, 4)
        .padding(.vertical, 4)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Colors.whitePrimary)
        }
        .contentShape(Rectangle())
    }

    private var sendCommentButton: some View {
        Button {
            Task {
                do {
                    try await viewModel.checkCommentRequirements()
                } catch {
                    showPopup(
                        text: error.userFriendlyDescription
                    )
                }
            }
        } label: {
            Circle()
                .foregroundStyle(Gradients.activeButtonBlue)
                .frame(width: 33, height: 33)
                .overlay {
                    Icons.arrowDownNormal
                        .iconSize(height: 22)
                        .rotationEffect(.degrees(270))
                        .foregroundStyle(Colors.whitePrimary)
                }
        }
        .disabled(viewModel.commentText.isEmpty)
    }

    private var contextMenu: some View {
        Section {
            Button(role: .destructive) {
                //
            } label: {
                Label("Report comment", systemImage: "xmark")
                    .font(.customFont(weight: .regular, size: .body))
            }
        }
    }
}
