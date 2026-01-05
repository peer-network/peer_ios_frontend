//
//  ShopRepository.swift
//  PeerApp
//
//  Created by Artem Vasin on 01.01.26.
//

import FirebaseFirestore

actor ShopCache {
    private var cache: [String: ShopItem] = [:]
    func get(_ id: String) -> ShopItem? { cache[id] }
    func set(_ item: ShopItem, for id: String) { cache[id] = item }
}

final class ShopRepository {
    private let db = Firestore.firestore()
    private let cache = ShopCache()

    func getShopItem(postId: String) async throws -> ShopItem? {
        if let cached = await cache.get(postId) { return cached }

        let snap = try await db.collection("shop").document(postId).getDocument()
        guard snap.exists else { return nil }

        let item = try snap.data(as: ShopItem.self)
        if let id = item.id {
            await cache.set(item, for: id)
        }
        return item
    }
}
