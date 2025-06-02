// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetDailyFreeQuery: GraphQLQuery {
  public static let operationName: String = "GetDailyFree"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetDailyFree { getDailyFreeStatus { __typename status ResponseCode affectedRows { __typename name used available } } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getDailyFreeStatus", GetDailyFreeStatus.self),
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
        .field("status", String.self),
        .field("ResponseCode", String.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

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

        public var name: String { __data["name"] }
        public var used: Int { __data["used"] }
        public var available: Int { __data["available"] }
      }
    }
  }
}
