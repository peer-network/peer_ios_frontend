//
//  ShopItem.swift
//  PeerApp
//
//  Created by Artem Vasin on 01.01.26.
//

import Foundation
import Models
import FirebaseFirestore

struct ShopListing: Identifiable, Hashable {
    var id: String { post.id }
    let post: Post
    let item: ShopItem
}

enum SizeOption: String, Codable {
    case sized
    case oneSize = "one_size_stock"
}

struct ShopItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?

    var name: String
    var description: String
    var price: Int

    // sized
    var sizes: [String: Int]?

    // one-size (Firestore field: "one_size_stock")
    var oneSizeStock: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, sizes
        case oneSizeStock = "one_size_stock"
    }

    var sizeOption: SizeOption {
        oneSizeStock != nil ? .oneSize : .sized
    }

    var inStock: Bool {
        switch sizeOption {
            case .sized:   return (sizes?.values.reduce(0, +) ?? 0) > 0
            case .oneSize: return (oneSizeStock ?? 0) > 0
        }
    }

    func stock(for size: String) -> Int { sizes?[size] ?? 0 }
}
