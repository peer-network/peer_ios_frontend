//
//  ShopItemPurchaseEntryView.swift
//  PeerApp
//
//  Created by Artem Vasin on 28.01.26.
//

import SwiftUI
import Models
import DesignSystem

struct ShopItemPurchaseEntryView: View {
    let post: Post
    private let repo: ShopItemRepository

    @StateObject private var vm: ShopSingleListingViewModel

    init(post: Post, repo: ShopItemRepository = FirestoreShopItemRepository()) {
        self.post = post
        self.repo = repo
        _vm = StateObject(wrappedValue: ShopSingleListingViewModel(repo: repo))
    }

    var body: some View {
        Group {
            switch vm.state {
                case .loading:
                    HeaderContainer(actionsToDisplay: .commentsAndLikes) {
                        Text("Back")
                    } content: {
                        ProgressView()
                            .controlSize(.large)
                            .padding(.top, 100)
                    }

                case .missing:
                    HeaderContainer(actionsToDisplay: .commentsAndLikes) {
                        Text("Back")
                    } content: {
                        ErrorView(
                            title: "Not available",
                            description: "This item is no longer available."
                        ) {
                            vm.load(post: post)
                        }
                        .padding(.top, 100)
                    }

                case .error(let msg):
                    HeaderContainer(actionsToDisplay: .commentsAndLikes) {
                        Text("Back")
                    } content: {
                        ErrorView(
                            title: "Error",
                            description: msg
                        ) {
                            vm.load(post: post)
                        }
                        .padding(.top, 100)
                    }

                case .ready(let listing):
                    HeaderContainer(actionsToDisplay: .commentsAndLikes) {
                        Text("Back")
                    } content: {
                        ScrollView {
                            ShopItemTileView(shopPost: listing, displayType: .list)
                                .padding(20)
                        }
                        .scrollIndicators(.hidden)
                    }
            }
        }
        .task(id: post.id) {
            vm.load(post: post)
        }
    }
}
