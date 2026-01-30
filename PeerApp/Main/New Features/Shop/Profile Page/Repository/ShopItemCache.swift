//
//  ShopItemCache.swift
//  PeerApp
//
//  Created by Artem Vasin on 06.01.26.
//

import Models

actor ShopItemCache {
    private var items: [String: ShopItem] = [:]
    private var permanentlyMissing: Set<String> = []
    private var transientFailed: Set<String> = []

    func item(for id: String) -> ShopItem? { items[id] }

    func items(for ids: [String]) -> [String: ShopItem] {
        var out: [String: ShopItem] = [:]
        out.reserveCapacity(ids.count)
        for id in ids {
            if let v = items[id] { out[id] = v }
        }
        return out
    }

    func unresolvedIDs(from ids: [String]) -> [String] {
        ids.filter {
            items[$0] == nil &&
            !permanentlyMissing.contains($0) &&
            !transientFailed.contains($0)
        }
    }

    func mergeFetched(_ fetched: [String: ShopItem], requestedIDs: [String]) {
        items.merge(fetched) { _, new in new }
        let missing = requestedIDs.filter { fetched[$0] == nil }
        permanentlyMissing.formUnion(missing)
    }

    func markFailed(_ ids: [String]) { transientFailed.formUnion(ids) }

    func resetForRefresh() { transientFailed.removeAll() }

    func resetAll() {
        items.removeAll()
        permanentlyMissing.removeAll()
        transientFailed.removeAll()
    }
}
