//
//  ShopRoute.swift
//  PeerApp
//
//  Created by Artem Vasin on 12.01.26.
//

import Foundation
import Models

public enum ShopRoute: Hashable {
    case purchase(item: ShopListing)
    case purchaseWithPost(post: Post)
    case checkout(flowID: UUID)
}
