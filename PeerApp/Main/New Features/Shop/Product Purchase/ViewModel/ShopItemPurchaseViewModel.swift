//
//  ShopItemPurchaseViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.01.26.
//

import Combine
import Environment
import Models

@MainActor
final class ShopItemPurchaseViewModel: ObservableObject {
    var apiService: APIService?

    let item: ShopListing

    init(item: ShopListing) {
        self.item = item
    }
}
