// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateNameMutation: GraphQLMutation {
  public static let operationName: String = "UpdateName"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateName($username: String!, $password: String!) { updateName(username: $username, password: $password) { __typename status ResponseCode } }"#
    ))

  public var username: String
  public var password: String

  public init(
    username: String,
    password: String
  ) {
    self.username = username
    self.password = password
  }

  public var __variables: Variables? { [
    "username": username,
    "password": password
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateName", UpdateName.self, arguments: [
        "username": .variable("username"),
        "password": .variable("password")
      ]),
    ] }

    public var updateName: UpdateName { __data["updateName"] }

    /// UpdateName
    ///
    /// Parent Type: `DefaultResponse`
    public struct UpdateName: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
