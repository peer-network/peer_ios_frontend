// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HelloQuery: GraphQLQuery {
  public static let operationName: String = "Hello"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Hello { hello { __typename currentuserid } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hello", Hello?.self),
    ] }

    public var hello: Hello? { __data["hello"] }

    /// Hello
    ///
    /// Parent Type: `HelloResponse`
    public struct Hello: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.HelloResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("currentuserid", GQLOperationsGuest.ID?.self),
      ] }

      public var currentuserid: GQLOperationsGuest.ID? { __data["currentuserid"] }
    }
  }
}
