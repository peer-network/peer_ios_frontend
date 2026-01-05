//
//  ShopProfileView.swift
//  PeerApp
//
//  Created by Artem Vasin on 05.01.26.
//

import SwiftUI
import DesignSystem
import ProfileNew
import Models
import Environment

struct ShopProfileView: View {
    @EnvironmentObject private var apiManager: APIServiceManager
    
    @StateObject private var viewModel: ProfileViewModel

    init() {
        _viewModel = .init(wrappedValue: .init(userId: "4cca9cfe-762b-416f-8e15-571f4d6798c9"))
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            pageContent
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            Task {
                await fetchEverything()
            }
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        if let user = viewModel.user {
            headerView(user: user)
        } else {
            ProgressView()
        }
    }

    private func headerView(user: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 10) {
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .shop, ignoreCache: false)

                VStack(alignment: .leading, spacing: 0) {
                    Text(user.username)
                        .appFont(.bodyBold)
                        .lineLimit(1)

                    Text(user.biography)
                        .appFont(.smallLabelRegular)
                }
                .multilineTextAlignment(.leading)
                .foregroundStyle(Colors.whitePrimary)
            }

            HStack(spacing: 10) {
                let vm = FollowButtonViewModel(
                    id: user.id,
                    isFollowing: user.isFollowed,
                    isFollowed: user.isFollowing
                )
                FollowButton2(viewModel: vm)

                let questionMarkBtnCfg = StateButtonConfig(buttonSize: .small, buttonType: .custom(textColor: Colors.blackDark, fillColor: Colors.whitePrimary), title: "", icon: IconsNew.questionmarkCircle, iconPlacement: .trailing)
                StateButton(config: questionMarkBtnCfg) {
                    //
                }
                .fixedSize()
            }
        }
        .padding(10)
        .background(Color(red: 0, green: 0.41, blue: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func fetchEverything() async {
        await viewModel.fetchUser()
        await viewModel.fetchBio()
    }
}
