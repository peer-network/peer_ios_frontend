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

    @StateObject private var headerVM: ProfileViewModel
    @StateObject private var catalogVM: ShopCatalogViewModel

    @State private var layout = ShopItemsDisplayType.list

    init(shopUserId: String) {
        _headerVM = .init(wrappedValue: .init(userId: shopUserId))
        _catalogVM = .init(
            wrappedValue: .init(
                shopUserId: shopUserId,
                repo: FirestoreShopItemRepository()
            )
        )
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            content
        }
        .onFirstAppear {
            headerVM.apiService = apiManager.apiService
            catalogVM.apiService = apiManager.apiService

            Task {
                await headerVM.fetchUser()
                await headerVM.fetchBio()
                catalogVM.fetchNextPage(reset: true)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let user = headerVM.user {
            ScrollView {
                LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        shopItemsView
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                    } header: {
                        VStack(spacing: 10) {
                            headerView(user: user)
                                .padding(.horizontal, 20)
                            ShopTabControllerView(type: $layout)
                        }
                        .padding(.top, 20)
                        .background(Colors.blackDark)
                    }
                }
            }
            .scrollIndicators(.hidden)
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

                    Text(headerVM.fetchedBio)
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

    @ViewBuilder
    private var shopItemsView: some View {
        switch catalogVM.state {
            case .loading:
                skeletonGridOrList
            case .error(let msg):
                ErrorView(title: "Error", description: msg) {
                    catalogVM.fetchNextPage(reset: true)
                }
            case .ready:
                gridOrList
        }
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    }

    @ViewBuilder
    private var gridOrList: some View {
        switch layout {
        case .grid:
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(catalogVM.listings) { listing in
                    ShopItemTileView(shopPost: listing, displayType: .grid)
                        .onFirstAppear { catalogVM.loadMoreIfNeeded(currentListingID: listing.id) }
                }
            }

        case .list:
            LazyVStack(spacing: 10) {
                ForEach(catalogVM.listings) { listing in
                    ShopItemTileView(shopPost: listing, displayType: .list)
                        .onFirstAppear { catalogVM.loadMoreIfNeeded(currentListingID: listing.id) }
                }
            }
        }
    }

    private var skeletonGridOrList: some View {
        let placeholders = Array(0..<10)
        return Group {
            switch layout {
                case .grid:
                    let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(placeholders, id: \.self) { _ in
                            Rectangle().fill(Colors.inactiveDark).aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .skeleton(isRedacted: true)
                        }
                    }
                case .list:
                    LazyVStack(spacing: 10) {
                        ForEach(placeholders, id: \.self) { _ in
                            Rectangle().fill(Colors.inactiveDark).frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .skeleton(isRedacted: true)
                        }
                    }
            }
        }
    }
}

import SwiftUI

struct ShopItemRow: View {
    let listing: ShopListing

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Colors.inactiveDark)
            .frame(height: 120)
            .overlay(alignment: .leading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(listing.item.name)
                    Text("\(listing.item.price) tokens").opacity(0.7)
                }
                .padding()
                .foregroundStyle(Colors.whitePrimary)
            }
    }
}

struct ShopItemTile: View {
    let listing: ShopListing

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Colors.inactiveDark)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.item.name)
                        .lineLimit(1)
                    Text("\(listing.item.price) tokens").opacity(0.7)
                        .opacity(0.7)
                }
                .padding(10)
                .foregroundStyle(Colors.whitePrimary)
            }
    }
}

