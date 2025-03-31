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

public struct CommentsView: View {
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @StateObject private var viewModel: CommentsViewModel

    @State private var commentText = ""

    public init(post: Post) {
        _viewModel = .init(wrappedValue: .init(post: post))
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(isBackgroundWhite ? Color.backgroundDark : Color.white)
                .padding(.bottom, 10)

            Text("Comments")
                .font(.customFont(weight: .regular, size: .body))
                .foregroundStyle(isBackgroundWhite ? Color.backgroundDark : Color.white)
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
                                        await viewModel.fetchComments()
                                    }
                                    .padding(.horizontal, 20)
                                case .none:
                                    EmptyView()
                            }
                        }
                    case .loading:
                        EmptyView()
                    case .error(let error):
                        EmptyView()
                }
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
    }
    
    private var commentTextField: some View {
        HStack(alignment: .center, spacing: 10) {
            TextField(text: $commentText, axis: .vertical) {
                Text("Write a comment...")
                    .foregroundStyle(Color.textSuggestions)
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
                .foregroundStyle(isBackgroundWhite ? Color.lightBlue : Color.white)
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
                .foregroundStyle(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.47, green: 0.69, blue: 1), location: 0.00),
                            Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0, y: 0.5),
                        endPoint: UnitPoint(x: 1, y: 0.5))
                )
                .frame(width: 33, height: 33)
                .overlay {
                    Icons.arrowDownNormal
                        .iconSize(height: 22)
                        .rotationEffect(.degrees(270))
                        .foregroundStyle(Color.white)
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
