// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PerformShopOrderMutation: GraphQLMutation {
  public static let operationName: String = "PerformShopOrder"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation PerformShopOrder($tokenAmount: Decimal!, $shopItemId: String!, $name: String!, $email: String!, $addressline1: String!, $addressline2: String, $city: String!, $zipcode: String!, $country: ShopSupportedDeliveryCountry!, $size: String) { performShopOrder( tokenAmount: $tokenAmount shopItemId: $shopItemId orderDetails: { name: $name email: $email addressline1: $addressline1 addressline2: $addressline2 country: $country zipcode: $zipcode city: $city shopItemSpecs: { size: $size } } ) { __typename status RequestId ResponseCode ResponseMessage } }"#
    ))

  public var tokenAmount: Decimal
  public var shopItemId: String
  public var name: String
  public var email: String
  public var addressline1: String
  public var addressline2: GraphQLNullable<String>
  public var city: String
  public var zipcode: String
  public var country: GraphQLEnum<ShopSupportedDeliveryCountry>
  public var size: GraphQLNullable<String>

  public init(
    tokenAmount: Decimal,
    shopItemId: String,
    name: String,
    email: String,
    addressline1: String,
    addressline2: GraphQLNullable<String>,
    city: String,
    zipcode: String,
    country: GraphQLEnum<ShopSupportedDeliveryCountry>,
    size: GraphQLNullable<String>
  ) {
    self.tokenAmount = tokenAmount
    self.shopItemId = shopItemId
    self.name = name
    self.email = email
    self.addressline1 = addressline1
    self.addressline2 = addressline2
    self.city = city
    self.zipcode = zipcode
    self.country = country
    self.size = size
  }

  public var __variables: Variables? { [
    "tokenAmount": tokenAmount,
    "shopItemId": shopItemId,
    "name": name,
    "email": email,
    "addressline1": addressline1,
    "addressline2": addressline2,
    "city": city,
    "zipcode": zipcode,
    "country": country,
    "size": size
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("performShopOrder", PerformShopOrder.self, arguments: [
        "tokenAmount": .variable("tokenAmount"),
        "shopItemId": .variable("shopItemId"),
        "orderDetails": [
          "name": .variable("name"),
          "email": .variable("email"),
          "addressline1": .variable("addressline1"),
          "addressline2": .variable("addressline2"),
          "country": .variable("country"),
          "zipcode": .variable("zipcode"),
          "city": .variable("city"),
          "shopItemSpecs": ["size": .variable("size")]
        ]
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PerformShopOrderMutation.Data.self
    ] }

    public var performShopOrder: PerformShopOrder { __data["performShopOrder"] }

    /// PerformShopOrder
    ///
    /// Parent Type: `DefaultResponse`
    public struct PerformShopOrder: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("RequestId", String?.self),
        .field("ResponseCode", String?.self),
        .field("ResponseMessage", String?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PerformShopOrderMutation.Data.PerformShopOrder.self
      ] }

      public var status: String { __data["status"] }
      public var requestId: String? { __data["RequestId"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var responseMessage: String? { __data["ResponseMessage"] }
    }
  }
}
