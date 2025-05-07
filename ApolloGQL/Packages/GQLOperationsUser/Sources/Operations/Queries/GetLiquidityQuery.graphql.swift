// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetLiquidityQuery: GraphQLQuery {
  public static let operationName: String = "GetLiquidity"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetLiquidity { balance { __typename status ResponseCode currentliquidity } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("balance", Balance.self),
    ] }

    public var balance: Balance { __data["balance"] }

    /// Balance
    ///
    /// Parent Type: `CurrentLiquidity`
    public struct Balance: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.CurrentLiquidity }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String.self),
        .field("currentliquidity", GQLOperationsUser.Decimal?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var currentliquidity: GQLOperationsUser.Decimal? { __data["currentliquidity"] }
    }
  }
}
