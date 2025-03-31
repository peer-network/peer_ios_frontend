// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetLiquidityQuery: GraphQLQuery {
  public static let operationName: String = "GetLiquidity"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetLiquidity { currentliquidity { __typename currentliquidity } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentliquidity", Currentliquidity.self),
    ] }

    public var currentliquidity: Currentliquidity { __data["currentliquidity"] }

    /// Currentliquidity
    ///
    /// Parent Type: `CurrentLiquidity`
    public struct Currentliquidity: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.CurrentLiquidity }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("currentliquidity", GQLOperationsUser.Decimal?.self),
      ] }

      public var currentliquidity: GQLOperationsUser.Decimal? { __data["currentliquidity"] }
    }
  }
}
