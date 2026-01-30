//
//  ShopOrder.swift
//  Models
//
//  Created by Artem Vasin on 15.01.26.
//

public struct ShopOrder {
    public let id: String
    public let itemId: String
    public let size: String?
    public let deilveryData: DeliveryData

    public init(id: String, itemId: String, size: String?, deilveryData: DeliveryData) {
        self.id = id
        self.itemId = itemId
        self.size = size
        self.deilveryData = deilveryData
    }
}
