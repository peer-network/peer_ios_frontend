// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdatePasswordMutation: GraphQLMutation {
  public static let operationName: String = "UpdatePassword"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdatePassword($password: String!, $expassword: String!) { updatePassword(password: $password, expassword: $expassword) { __typename status RequestId ResponseCode ResponseMessage } }"#
    ))

  public var password: String
  public var expassword: String

  public init(
    password: String,
    expassword: String
  ) {
    self.password = password
    self.expassword = expassword
  }

  public var __variables: Variables? { [
    "password": password,
    "expassword": expassword
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updatePassword", UpdatePassword.self, arguments: [
        "password": .variable("password"),
        "expassword": .variable("expassword")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdatePasswordMutation.Data.self
    ] }

    public var updatePassword: UpdatePassword { __data["updatePassword"] }

    /// UpdatePassword
    ///
    /// Parent Type: `DefaultResponse`
    public struct UpdatePassword: GQLOperationsUser.SelectionSet {
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
        UpdatePasswordMutation.Data.UpdatePassword.self
      ] }

      public var status: String { __data["status"] }
      public var requestId: String { __data["RequestId"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var responseMessage: String { __data["ResponseMessage"] }
    }
  }
}
