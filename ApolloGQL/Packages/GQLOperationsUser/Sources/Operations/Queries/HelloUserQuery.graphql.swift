// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HelloUserQuery: GraphQLQuery {
  public static let operationName: String = "HelloUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query HelloUser { hello { __typename currentuserid currentVersion wikiLink } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("hello", Hello.self),
    ] }

    public var hello: Hello { __data["hello"] }

    /// Hello
    ///
    /// Parent Type: `HelloResponse`
    public struct Hello: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.HelloResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("currentuserid", GQLOperationsUser.ID?.self),
        .field("currentVersion", String?.self),
        .field("wikiLink", String?.self),
      ] }

      public var currentuserid: GQLOperationsUser.ID? { __data["currentuserid"] }
      public var currentVersion: String? { __data["currentVersion"] }
      public var wikiLink: String? { __data["wikiLink"] }
    }
  }
}
