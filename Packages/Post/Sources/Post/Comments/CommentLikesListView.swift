//
//  CommentLikesListView.swift
//  Post
//
//  Created by Artem Vasin on 15.09.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

public struct CommentLikesListView: View {
    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var router: Router

    @StateObject private var viewModel: SingleCommentViewModel

    public init(comment: Comment) {
        _viewModel = .init(wrappedValue: SingleCommentViewModel(comment: comment))
    }

    public var body: some View {
        VStack(spacing: 0) {
            pageHeaderView
                .padding(.bottom, 10)
                .padding(.horizontal, 20)

            ScrollView {
                LazyVStack(spacing: 15) {
                    switch viewModel.likesState {
                        case .loading:
                            ForEach(RowUser.placeholders(count: 10)) { user in
                                RowProfileView(user: user, trailingContent: {
                                    let vm = FollowButtonViewModel(
                                        id: user.id,
                                        isFollowing: user.isFollowing,
                                        isFollowed: user.isFollowed
                                    )
                                    FollowButton2(viewModel: vm)
                                        .fixedSize(horizontal: true, vertical: false)
                                }, dismissAction: nil)
                                .allowsHitTesting(false)
                                .skeleton(isRedacted: true)
                            }
                        case .display:
                            if viewModel.likedBy.isEmpty {
                                Text("No likes yet...")
                                    .padding(.top, 20)
                            } else {
                                ForEach(viewModel.likedBy) { user in
                                    RowProfileView(user: user, trailingContent: {
                                        let vm = FollowButtonViewModel(
                                            id: user.id,
                                            isFollowing: user.isFollowing,
                                            isFollowed: user.isFollowed
                                        )
                                        FollowButton2(viewModel: vm)
                                            .fixedSize(horizontal: true, vertical: false)
                                    }, dismissAction: nil)
                                }

                                if viewModel.hasMoreLikes {
                                    NextPageView {
                                        viewModel.fetchLikes(reset: false)
                                    }
                                } else {
                                    EmptyView()
                                }
                            }
                        case .error(let error):
                            ErrorView(title: "Error", description: error.userFriendlyDescription) {
                                viewModel.fetchLikes(reset: true)
                            }
                            .padding(20)
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.textActive.ignoresSafeArea())
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.fetchLikes(reset: true)
        }
    }

    private var pageHeaderView: some View {
        Button {
            router.path.removeLast()
        } label: {
            Icons.arrowDown
                .iconSize(height: 7)
                .rotationEffect(.degrees(90))
                .frame(width: 24, height: 24)
                .foregroundStyle(Colors.whitePrimary)
                .contentShape(.rect)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            Text("Likes")
                .font(.custom(.bodyBold))
                .foregroundStyle(Colors.whitePrimary)
        }
    }
}
