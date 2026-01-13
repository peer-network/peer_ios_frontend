//
//  ShopRoute.swift
//  PeerApp
//
//  Created by Artem Vasin on 12.01.26.
//

import Foundation

enum ShopRoute: Hashable {
    case purchase(item: ShopListing)
    case checkout(flowID: UUID)
}
