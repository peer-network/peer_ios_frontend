//
//  ShopItemTileView.swift
//  PeerApp
//
//  Created by Artem Vasin on 05.01.26.
//

import SwiftUI
import DesignSystem
import Post
import NukeUI
import Environment

struct ShopItemTileView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var postVM: PostViewModel

    let shopPost: ShopListing

    private let displayType: ShopItemsDisplayType

    @State private var shareSheetHeight: Double = 20

    init(shopPost: ShopListing, displayType: ShopItemsDisplayType) {
        self.displayType = displayType
        self.shopPost = shopPost
        _postVM = .init(wrappedValue: PostViewModel(post: shopPost.post))
    }

    var body: some View {
        Group {
            switch displayType {
                case .list:
                    listTileView
                case .grid:
                    gridTileView
            }
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .padding(.bottom, 10)
        .background {
            Colors.inactiveDark
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onFirstAppear {
            postVM.apiService = apiManager.apiService
        }
        .sheet(isPresented: $postVM.showCommentsSheet) {
            CommentsListView(viewModel: postVM)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .presentationBackground(Colors.blackDark)
                .presentationDetents([.fraction(0.75), .large])
                .presentationContentInteraction(.resizes)
        }
        .sheet(isPresented: $postVM.showInteractionsSheet) {
            InteractionsView(viewModel: postVM)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .presentationBackground(Colors.blackDark)
                .presentationDetents([.fraction(0.75), .large])
                .presentationContentInteraction(.resizes)
        }
        .sheet(isPresented: $postVM.showShareSheet) {
            PostShareBottomSheet(viewModel: postVM)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                    withAnimation {
                        self.shareSheetHeight = height + 20
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .presentationBackground(Colors.blackDark)
                .presentationDetents([.height(shareSheetHeight)])
        }
    }

    private var listTileView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ImagesContent(postVM: postVM, aspectRatio: 1)
                .padding(.bottom, 10)

            Group {
                HStack(spacing: 0) {
                    PostActionsView(layout: .horizontal, postViewModel: postVM)
                }
                .padding(.bottom, 5)

                HStack(spacing: 0) {
                    Text(shopPost.item.name)
                        .appFont(.bodyBold)

                    Spacer(minLength: 10)
                        .layoutPriority(-1)

                    HStack(spacing: 5) {
                        Text(shopPost.item.price, format: .number)
                            .appFont(.largeTitleBold)

                        Icons.logoCircleWhite
                            .iconSize(height: 16.5)
                    }
                }
                .padding(.bottom, 10)

                Text(shopPost.item.description)
                    .appFont(.smallLabelRegular)
                    .padding(.bottom, 10)

                HStack(spacing: 10) {
                    buyButtonView

                    shareButtonView
                }
            }
            .padding(.horizontal, 10)
        }
        .modifier(ViewVisibilityModifier(viewed: postVM.isViewed, viewAction: {
            Task {
                try? await postVM.view()
            }
        }))
    }

    private var gridTileView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ImagesContent(postVM: postVM, aspectRatio: 1)
                .overlay(alignment: .topTrailing) {
                    shareButtonView
                        .padding(.top, 5)
                        .padding(.trailing, 5)
                }

            Group {
                PostActionsSmallView(postViewModel: postVM)

                Text(shopPost.item.name)
                    .appFont(.bodyBold)
                    .lineLimit(2, reservesSpace: true)

                HStack(spacing: 0) {
                    Text("Price")
                        .appFont(.smallLabelRegular)
                        .foregroundStyle(Colors.whiteSecondary)

                    Spacer(minLength: 5)
                        .layoutPriority(-1)

                    HStack(spacing: 2) {
                        Text(shopPost.item.price, format: .number)
                            .appFont(.bodyBold)

                        Icons.logoCircleWhite
                            .iconSize(height: 11)
                    }
                }

                buyButtonView
            }
            .padding(.horizontal, 10)
        }
    }

    @ViewBuilder
    private var buyButtonView: some View {
        var btnCfg: StateButtonConfig {
            if shopPost.item.inStock {
                StateButtonConfig(buttonSize: .small, buttonType: .primary, title: "Buy")
            } else {
                StateButtonConfig(buttonSize: .small, buttonType: .custom(textColor: Colors.whiteSecondary, fillColor: Colors.blackDark), title: "Out of stock")
            }
        }

        StateButton(config: btnCfg) {
            router.navigate(to: ShopRoute.purchase(item: shopPost))
        }
        .disabled(!shopPost.item.inStock)
    }

    @ViewBuilder
    private var shareButtonView: some View {
        let btnCfg = StateButtonConfig(
            buttonSize: .small,
            buttonType: .custom(textColor: Colors.whitePrimary, fillColor: Colors.blackDark),
            title: "",
            icon: Icons.share,
            iconPlacement: .trailing
        )
        

        StateButton(config: btnCfg) {
            postVM.showShareSheet = true
        }
        .fixedSize()
    }
}
