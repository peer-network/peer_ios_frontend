//
//  ShopItem.swift
//  PeerApp
//
//  Created by Artem Vasin on 01.01.26.
//

import Foundation
import FirebaseFirestore

public struct ShopListing: Identifiable, Hashable {
    public var id: String { post.id }
    public let post: Post
    public let item: ShopItem

    public init(post: Post, item: ShopItem) {
        self.post = post
        self.item = item
    }
}

public enum SizeOption: String, Codable {
    case sized
    case oneSize = "one_size_stock"
}

public struct ShopItem: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?

    public var name: String
    public var description: String
    public var price: Int

    // sized
    public var sizes: [String: Int]?

    // one-size (Firestore field: "one_size_stock")
    public var oneSizeStock: Int?

    public enum CodingKeys: String, CodingKey {
        case id, name, description, price, sizes
        case oneSizeStock = "one_size_stock"
    }

    public var sizeOption: SizeOption {
        oneSizeStock != nil ? .oneSize : .sized
    }

    public var inStock: Bool {
        switch sizeOption {
            case .sized:   return (sizes?.values.reduce(0, +) ?? 0) > 0
            case .oneSize: return (oneSizeStock ?? 0) > 0
        }
    }

    public func stock(for size: String) -> Int { sizes?[size] ?? 0 }
}
