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

    @State private var typeSelected = ShopItemsDisplayType.list

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
            ScrollView {
                LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        LazyVStack(spacing: 8) {
                            ForEach(0...100, id: \.self) { idx in
                                Rectangle()
                                    .fill(Colors.inactiveDark)
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        Text("Post \(idx)")
                                            .appFont(.bodyRegular)
                                            .foregroundStyle(Colors.whitePrimary.opacity(0.7))
                                    )
                            }
                        }
                    } header: {
                        VStack(spacing: 10) {
                            headerView(user: user)
                                .padding(.horizontal, 20)

                            ShopTabControllerView(type: $typeSelected)
                        }
                        .padding(.top, 20)
                        .background(Colors.blackDark)
                    }

                }
            }
        } else {
            ProgressView()
        }
    }

    private func headerView(user: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 10) {
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .shop, ignoreCache: false)

                VStack(alignment: .leading, spacing: 0) {
                    Text(user.username)
                        .appFont(.bodyBold)
                        .lineLimit(1)

                    Text(viewModel.fetchedBio)
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
