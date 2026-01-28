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
                ProgressView()
                    .controlSize(.large)

            case .missing:
                ErrorView(
                    title: "Not available",
                    description: "This item is no longer available."
                ) {
                    vm.load(post: post)
                }

            case .error(let msg):
                ErrorView(
                    title: "Error",
                    description: msg
                ) {
                    vm.load(post: post)
                }

            case .ready(let listing):
                ShopItemPurchaseView(item: listing)
            }
        }
        .task(id: post.id) {
            vm.load(post: post)
        }
    }
}
