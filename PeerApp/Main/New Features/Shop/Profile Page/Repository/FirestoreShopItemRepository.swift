//
//  FirestoreShopItemRepository.swift
//  PeerApp
//
//  Created by Artem Vasin on 06.01.26.
//

import FirebaseFirestore

protocol ShopItemRepository {
    /// Keyed by documentID (postId)
    func fetchItems(postIDs: [String]) async throws -> [String: ShopItem]
}

final class FirestoreShopItemRepository: ShopItemRepository {
    private let collection: CollectionReference

    init(db: Firestore = .firestore(), collectionName: String = "shop") {
        self.collection = db.collection(collectionName)
    }

    func fetchItems(postIDs: [String]) async throws -> [String: ShopItem] {
        let ids = Array(Set(postIDs)).filter { !$0.isEmpty }
        guard !ids.isEmpty else { return [:] }

        let chunks = ids.chunked(into: 10)

        return try await withThrowingTaskGroup(of: [String: ShopItem].self) { group in
            for chunk in chunks {
                group.addTask { [collection] in
                    let snap = try await collection
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments()

                    var partial: [String: ShopItem] = [:]
                    for doc in snap.documents {
                        // If one doc fails to decode -> just skip it (treated as missing)
                        if let item = try? doc.data(as: ShopItem.self),
                           let id = item.id {
                            partial[id] = item
                        }
                    }
                    return partial
                }
            }

            var merged: [String: ShopItem] = [:]
            for try await partial in group {
                merged.merge(partial) { _, new in new }
            }
            return merged
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map { start in
            Array(self[start..<Swift.min(start + size, count)])
        }
    }
}
