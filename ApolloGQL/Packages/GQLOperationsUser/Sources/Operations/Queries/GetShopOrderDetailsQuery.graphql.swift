// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetShopOrderDetailsQuery: GraphQLQuery {
  public static let operationName: String = "GetShopOrderDetails"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetShopOrderDetails($transactionId: String!) { shopOrderDetails(transactionId: $transactionId) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename shopOrderId shopItemId createdat shopItemSpecs { __typename size } deliveryDetails { __typename name email addressline1 addressline2 city zipcode country } } meta { __typename status RequestId ResponseCode ResponseMessage } } }"#
    ))

  public var transactionId: String

  public init(transactionId: String) {
    self.transactionId = transactionId
  }

  public var __variables: Variables? { ["transactionId": transactionId] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("shopOrderDetails", ShopOrderDetails.self, arguments: ["transactionId": .variable("transactionId")]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetShopOrderDetailsQuery.Data.self
    ] }

    public var shopOrderDetails: ShopOrderDetails { __data["shopOrderDetails"] }

    /// ShopOrderDetails
    ///
    /// Parent Type: `ShopOrderDetailsResponse`
    public struct ShopOrderDetails: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ShopOrderDetailsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetShopOrderDetailsQuery.Data.ShopOrderDetails.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows { __data["affectedRows"] }

      /// ShopOrderDetails.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String.self),
          .field("ResponseCode", String.self),
          .field("ResponseMessage", String.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetShopOrderDetailsQuery.Data.ShopOrderDetails.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// ShopOrderDetails.AffectedRows
      ///
      /// Parent Type: `ShopOrderDetails`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ShopOrderDetails }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("shopOrderId", String.self),
          .field("shopItemId", String.self),
          .field("createdat", GQLOperationsUser.Date.self),
          .field("shopItemSpecs", ShopItemSpecs?.self),
          .field("deliveryDetails", DeliveryDetails.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetShopOrderDetailsQuery.Data.ShopOrderDetails.AffectedRows.self
        ] }

        public var shopOrderId: String { __data["shopOrderId"] }
        public var shopItemId: String { __data["shopItemId"] }
        public var createdat: GQLOperationsUser.Date { __data["createdat"] }
        public var shopItemSpecs: ShopItemSpecs? { __data["shopItemSpecs"] }
        public var deliveryDetails: DeliveryDetails { __data["deliveryDetails"] }

        /// ShopOrderDetails.AffectedRows.ShopItemSpecs
        ///
        /// Parent Type: `ShopItemSpecs`
        public struct ShopItemSpecs: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ShopItemSpecs }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("size", String.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetShopOrderDetailsQuery.Data.ShopOrderDetails.AffectedRows.ShopItemSpecs.self
          ] }

          public var size: String { __data["size"] }
        }

        /// ShopOrderDetails.AffectedRows.DeliveryDetails
        ///
        /// Parent Type: `ShopOrderDeliveryDetails`
        public struct DeliveryDetails: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ShopOrderDeliveryDetails }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("email", String.self),
            .field("addressline1", String.self),
            .field("addressline2", String?.self),
            .field("city", String.self),
            .field("zipcode", String.self),
            .field("country", String.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetShopOrderDetailsQuery.Data.ShopOrderDetails.AffectedRows.DeliveryDetails.self
          ] }

          public var name: String { __data["name"] }
          public var email: String { __data["email"] }
          public var addressline1: String { __data["addressline1"] }
          public var addressline2: String? { __data["addressline2"] }
          public var city: String { __data["city"] }
          public var zipcode: String { __data["zipcode"] }
          public var country: String { __data["country"] }
        }
      }
    }
  }
}
