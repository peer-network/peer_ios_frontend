// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HelloUserQuery: GraphQLQuery {
  public static let operationName: String = "HelloUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query HelloUser { hello { __typename currentuserid userroles userRoleString currentVersion wikiLink lastMergedPullRequestNumber companyAccountId } }"#
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
        .field("userroles", Int.self),
        .field("userRoleString", String.self),
        .field("currentVersion", String?.self),
        .field("wikiLink", String?.self),
        .field("lastMergedPullRequestNumber", String?.self),
        .field("companyAccountId", GQLOperationsUser.ID?.self),
      ] }

      public var currentuserid: GQLOperationsUser.ID? { __data["currentuserid"] }
      public var userroles: Int { __data["userroles"] }
      public var userRoleString: String { __data["userRoleString"] }
      public var currentVersion: String? { __data["currentVersion"] }
      public var wikiLink: String? { __data["wikiLink"] }
      public var lastMergedPullRequestNumber: String? { __data["lastMergedPullRequestNumber"] }
      public var companyAccountId: GQLOperationsUser.ID? { __data["companyAccountId"] }
    }
  }
}
