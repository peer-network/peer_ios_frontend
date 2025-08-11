//
//  BlockedUsersPageView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 18.06.25.
//

import SwiftUI
import Environment
import DesignSystem
import Models

public struct BlockedUsersPageView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel = BlockedUsersViewModel()

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Blocked Users")
        } content: {
            pageContent
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.getMyBlockedUsers(reset: true)
        }
        // TODO: Add screen tracking
    }

    private var pageContent: some View {
        ScrollView {
            blockedUsersView
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.horizontal, 20)
        }
        .refreshable {
            viewModel.getMyBlockedUsers(reset: true)
        }
    }

    @ViewBuilder
    private var blockedUsersView: some View {
        switch viewModel.state {
            case .loading:
                blockedUsersList(users: RowUser.placeholders(count: 5))
                    .skeleton(isRedacted: true)
                    .allowsHitTesting(false)
            case .display:
                blockedUsersList(users: viewModel.blockedUsers)
            case .error(let error):
                ErrorView(title: "Error", description: error.userFriendlyDescription) {
                    viewModel.getMyBlockedUsers(reset: true)
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func blockedUsersList(users: [RowUser]) -> some View {
        if users.isEmpty {
            Text("You haven't blocked anyone yet.")
                .font(.customFont(weight: .regular, style: .callout))
                .foregroundStyle(Colors.whitePrimary)
        } else {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("Content of these users is not shown in your Feed:")
                    .font(.customFont(weight: .regular, style: .callout))
                    .foregroundStyle(Colors.whitePrimary)

                ForEach(users) { user in
                    RowProfileView(user: user) {
                        UnblockUserXButton(userId: user.id) {
                            withAnimation {
                                viewModel.removeBlockedUser(with: user.id)
                            }
                        }
                    }
                }

                if viewModel.hasMoreBlockedUsers {
                    NextPageView {
                        viewModel.getMyBlockedUsers(reset: false)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
