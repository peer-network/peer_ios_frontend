//
//  DeliveryData.swift
//  Models
//
//  Created by Artem Vasin on 15.01.26.
//

public struct DeliveryData {
    public let name: String
    public let email: String
    public let address1: String
    public let address2: String?
    public let city: String
    public let zip: String
    public let country: String

    public init(name: String, email: String, address1: String, address2: String?, city: String, zip: String, country: String) {
        self.name = name
        self.email = email
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.zip = zip
        self.country = country
    }
}
