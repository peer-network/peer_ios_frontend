//
//  InteractionsView.swift
//  Post
//
//  Created by Artem Vasin on 04.08.25.
//

import SwiftUI
import DesignSystem
import Models

@MainActor
enum InteractionType {
    case likes, dislikes, views

    var icon: some View {
        switch self {
            case .likes:
                Icons.heartFill
                    .iconSize(height: 19)
                    .foregroundStyle(Colors.redAccent)
            case .dislikes:
                Icons.heartBrokeFill
                    .iconSize(height: 19)
                    .foregroundStyle(Colors.redAccent)
            case .views:
                Icons.eyeCircledFill
                    .iconSize(height: 19)
                    .foregroundStyle(Colors.whitePrimary)
        }
    }

    func getAmount(viewModel: PostViewModel) -> Int? {
        switch self {
            case .likes:
                return viewModel.amountLikes
            case .dislikes:
                return viewModel.amountDislikes
            case .views:
                return viewModel.amountViews
        }
    }

    var stringValue: String {
        switch self {
            case .likes: "likes"
            case .dislikes: "dislikes"
            case .views: "views"
        }
    }
}

struct InteractionsView: View {
    @ObservedObject var viewModel: PostViewModel

    init(viewModel: PostViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.bottom, 25)

            InteractionsHeaderView(interactionsPage: $viewModel.interactionsTypeForSheet, viewModel: viewModel, interactions: [.likes, .dislikes, .views])
                .padding(.horizontal, 20)

            ScrollView {
                LazyVStack(spacing: 15) {
                    switch viewModel.interactionsState {
                        case .display:
                            if viewModel.interactions.isEmpty {
                                Text("No \(viewModel.interactionsTypeForSheet.stringValue) yet...")
                                    .padding(.top, 20)
                            } else {
                                ForEach(viewModel.interactions) { user in
                                    RowProfileView(user: user, trailingContent: {
                                        let vm = FollowButtonViewModel(
                                            id: user.id,
                                            isFollowing: user.isFollowing,
                                            isFollowed: user.isFollowed
                                        )
                                        FollowButton2(viewModel: vm)
                                            .fixedSize(horizontal: true, vertical: false)
                                    }, dismissAction: {
                                        viewModel.showInteractionsSheet = false
                                    })
                                }

                                if viewModel.hasMoreInteractions {
                                    NextPageView {
                                        viewModel.fetchInteractions(reset: false)
                                    }
                                } else {
                                    EmptyView()
                                }
                            }
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
                        case .error(let error):
                            ErrorView(title: "Error", description: error.userFriendlyDescription) {
                                viewModel.fetchInteractions(reset: true)
                            }
                            .padding(20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
                .padding(.top, 15)
            }
            .scrollDismissesKeyboard(.never)
            .scrollIndicators(.hidden)
        }
        .padding(.top, 10)
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: viewModel.interactionsTypeForSheet) {
            viewModel.fetchInteractions(reset: true)
        }
        .onFirstAppear {
            viewModel.fetchInteractions(reset: true)
        }
    }
}
