// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateNameMutation: GraphQLMutation {
  public static let operationName: String = "UpdateName"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateName($username: String!, $password: String!) { updateUsername(username: $username, password: $password) { __typename status RequestId ResponseCode ResponseMessage } }"#
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
      .field("updateUsername", UpdateUsername.self, arguments: [
        "username": .variable("username"),
        "password": .variable("password")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdateNameMutation.Data.self
    ] }

    public var updateUsername: UpdateUsername { __data["updateUsername"] }

    /// UpdateUsername
    ///
    /// Parent Type: `DefaultResponse`
    public struct UpdateUsername: GQLOperationsUser.SelectionSet {
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
        UpdateNameMutation.Data.UpdateUsername.self
      ] }

      public var status: String { __data["status"] }
      public var requestId: String { __data["RequestId"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var responseMessage: String { __data["ResponseMessage"] }
    }
  }
}
