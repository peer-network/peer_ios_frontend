//
//  ShopItemPurchaseViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.01.26.
//

import Combine
import Environment
import Models
import Foundation

@MainActor
final class ShopItemPurchaseViewModel: ObservableObject {
    var apiService: APIService?
    var router: Router?
    var tabSwitch: TabSwitchAction?
    var popupService: (any SystemPopupManaging)?

    let item: ShopListing

    @Published var selectedSize: String?

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var address1: String = ""
    @Published var address2: String = ""
    @Published var city: String = ""
    @Published var zip: String = ""
    @Published var country: String = "Germany"

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

    func purchase() async -> Bool {
        guard let apiService else { return false }

        let fixedAddress2 = address2.isEmpty ? nil : address2.trimmingCharacters(in: .whitespacesAndNewlines)

        let deliveryData = DeliveryData(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            address1: address1.trimmingCharacters(in: .whitespacesAndNewlines),
            address2: fixedAddress2,
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            zip: zip.trimmingCharacters(in: .whitespacesAndNewlines),
            country: country.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        let result = await apiService.performShopOrder(deliveryData: deliveryData, price: Foundation.Decimal(item.item.price), itemId: item.id, size: selectedSize)

        switch result {
            case .success:
                popupService?.presentPopup(.shopPurchaseSuccess) {
                    self.router?.pop(amount: 2)
                } cancel: {
                    self.router?.pop(amount: 2)
                }
                return true
            case .failure(let apiError):
                popupService?.presentPopup(.shopPurchaseFailed(error: apiError.userFriendlyMessage)) {
                    Task {
                        await self.purchase()
                    }
                }
                return false
        }
    }
}
