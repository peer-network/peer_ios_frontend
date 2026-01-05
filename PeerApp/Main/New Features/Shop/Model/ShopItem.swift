//
//  ShopItem.swift
//  PeerApp
//
//  Created by Artem Vasin on 01.01.26.
//

import Foundation
import FirebaseFirestore
import Models

struct ShopPost: Identifiable, Hashable {
    var id: String { post.id }
    let post: Post
    let item: ShopItem?   // nil while loading / if missing
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
    var sizeOption: SizeOption

    // sized
    var sizes: [String: Int]?

    // one-size
    var oneSizeStock: Int?

    var inStock: Bool {
        switch sizeOption {
            case .sized:
                return (sizes?.values.reduce(0, +) ?? 0) > 0
            case .oneSize:
                return (oneSizeStock ?? 0) > 0
        }
    }

    func stock(for size: String) -> Int {
        sizes?[size] ?? 0
    }
}
