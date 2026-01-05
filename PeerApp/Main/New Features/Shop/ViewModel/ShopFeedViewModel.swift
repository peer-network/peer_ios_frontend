//
//  ShopFeedViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 01.01.26.
//

import SwiftUI
import Models

@MainActor
final class ShopFeedViewModel: ObservableObject {
    @Published private(set) var shopPosts: [ShopPost] = []
    @Published var isLoading = false
    @Published var errorText: String?

    private let shopRepo = ShopRepository()

    func load(postsFromBackend: [Post]) {
        // show posts immediately with item=nil (skeleton/placeholder)
        shopPosts = postsFromBackend.map { ShopPost(post: $0, item: nil) }

        Task { await enrichWithFirestore(postsFromBackend) }
    }

    private func enrichWithFirestore(_ posts: [Post]) async {
        isLoading = true
        defer { isLoading = false }

        do {
            var idToItem: [String: ShopItem] = [:]

            try await withThrowingTaskGroup(of: (String, ShopItem?).self) { group in
                for post in posts {
                    group.addTask {
                        let item = try await self.shopRepo.getShopItem(postId: post.id)
                        return (post.id, item)
                    }
                }

                for try await (id, item) in group {
                    if let item { idToItem[id] = item }
                }
            }

            // merge into existing list, keep order
            shopPosts = posts.map { post in
                ShopPost(post: post, item: idToItem[post.id])
            }
        } catch {
            errorText = error.localizedDescription
        }
    }
}
