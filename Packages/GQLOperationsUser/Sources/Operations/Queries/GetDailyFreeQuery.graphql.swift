// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDailyFreeQuery: GraphQLQuery {
  public static let operationName: String = "GetDailyFree"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetDailyFree { getDailyFreeStatus { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename name used available } } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getDailyFreeStatus", GetDailyFreeStatus.self),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetDailyFreeQuery.Data.self
    ] }

    public var getDailyFreeStatus: GetDailyFreeStatus { __data["getDailyFreeStatus"] }

    /// GetDailyFreeStatus
    ///
    /// Parent Type: `GetDailyResponse`
    public struct GetDailyFreeStatus: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.GetDailyResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetDailyFreeQuery.Data.GetDailyFreeStatus.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// GetDailyFreeStatus.Meta
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
          GetDailyFreeQuery.Data.GetDailyFreeStatus.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// GetDailyFreeStatus.AffectedRow
      ///
      /// Parent Type: `DailyFreeResponse`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DailyFreeResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("used", Int.self),
          .field("available", Int.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetDailyFreeQuery.Data.GetDailyFreeStatus.AffectedRow.self
        ] }

        public var name: String { __data["name"] }
        public var used: Int { __data["used"] }
        public var available: Int { __data["available"] }
      }
    }
  }
}
