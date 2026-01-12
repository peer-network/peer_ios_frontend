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

    @Published var selectedSize: String?

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var address1: String = ""
    @Published var address2: String = ""
    @Published var city: String = ""
    @Published var zip: String = ""
    @Published var country: String = ""

    var canDoPurchase: Bool {
        guard !name.isEmpty && !email.isEmpty && !address1.isEmpty && !city.isEmpty && !zip.isEmpty && !country.isEmpty else {
            return false
        }

        if item.item.sizeOption == .sized && selectedSize == nil {
            return false
        }

        return true
    }

    init(item: ShopListing) {
        self.item = item
    }
}
