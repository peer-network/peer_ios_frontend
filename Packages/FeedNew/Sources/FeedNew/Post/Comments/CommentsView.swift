//
//  CommentsView.swift
//  FeedNew
//
//  Created by Артем Васин on 04.02.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment
import Analytics

public struct CommentsView: View {
    @Environment(\.analytics) private var analytics
    
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite
    @EnvironmentObject private var apiManager: APIServiceManager
    @StateObject private var viewModel: CommentsViewModel

    @State private var commentText = ""

    public init(post: Post) {
        _viewModel = .init(wrappedValue: .init(post: post))
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
                .padding(.bottom, 10)

            Text("Comments")
                .font(.customFont(weight: .regular, size: .body))
                .foregroundStyle(isBackgroundWhite ? Colors.textActive : Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)

            ScrollView {
                PostDescriptionComment(isInFeed: false)
                    .environmentObject(PostViewModel(post: viewModel.post))

                switch viewModel.state {
                    case .display(let comments, let hasMore):
                        if comments.isEmpty {
                            Text("No comments yet...")
                                .padding(.top, 30)
                        } else {
                            ForEach(comments) { comment in
                                SingleCommentView(comment: comment)
                                    .padding(.vertical, 5)
                                    .contentShape(Rectangle())
                                    .environmentObject(viewModel)
                            }

                            switch hasMore {
                                case .hasMore:
                                    NextPageView {
                                        viewModel.fetchComments()
                                    }
                                    .padding(.horizontal, 20)
                                case .none:
                                    EmptyView()
                            }
                        }
                    case .loading:
                        ForEach(Comment.placeholders(count: 15)) { comment in
                            SingleCommentView(comment: comment)
                                .padding(.vertical, 5)
                                .contentShape(Rectangle())
                                .environmentObject(viewModel)
                                .allowsHitTesting(false)
                                .skeleton(isRedacted: true)
                        }
                    case .error(_):
                        EmptyView()
                }
            }
            .onFirstAppear {
                viewModel.apiService = apiManager.apiService
                viewModel.fetchComments()
            }
            .scrollDismissesKeyboard(.never)
            .scrollIndicators(.hidden)
            .padding(.bottom, 5)
            .padding(.top, 5)

            HStack(alignment: .center, spacing: 10) {
                if let user = AccountManager.shared.user {
                    ProfileAvatarView(url: user.imageURL, name: user.username, config: .comment)
                }

                commentTextField
            }
            .padding(.top, 5)
        }
        .padding(10)
        .trackScreen(AppScreen.commentsSheet)
    }
    
    private var commentTextField: some View {
        HStack(alignment: .center, spacing: 10) {
            TextField(text: $commentText, axis: .vertical) {
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
                .foregroundStyle(isBackgroundWhite ? Colors.blueLight : Colors.whitePrimary)
        }
        .contentShape(Rectangle())
    }
    
    private var sendCommentButton: some View {
        Button {
            Task {
                do {
                    try await viewModel.sendComment(commentText)
                    showPopup(
                        text: "You used 1 comment! Free comments left for today: \(AccountManager.shared.dailyFreeComments)"
                    )
                } catch {
                    AccountManager.shared.increaseFreeComments()
                }
                commentText = ""
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
        .disabled(commentText.isEmpty)
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

#Preview {
    ZStack {
        Color.green
        
        CommentsView(post: .placeholderText())
            .environment(\.isBackgroundWhite, true)
    }
}
