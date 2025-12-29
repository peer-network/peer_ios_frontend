// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ConfirmPasswordResetMutation: GraphQLMutation {
  public static let operationName: String = "ConfirmPasswordReset"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation ConfirmPasswordReset($token: String!, $password: String!) { resetPassword(token: $token, password: $password) { __typename status ResponseCode } }"#
    ))

  public var token: String
  public var password: String

  public init(
    token: String,
    password: String
  ) {
    self.token = token
    self.password = password
  }

  public var __variables: Variables? { [
    "token": token,
    "password": password
  ] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("resetPassword", ResetPassword.self, arguments: [
        "token": .variable("token"),
        "password": .variable("password")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ConfirmPasswordResetMutation.Data.self
    ] }

    public var resetPassword: ResetPassword { __data["resetPassword"] }

    /// ResetPassword
    ///
    /// Parent Type: `DefaultResponse`
    public struct ResetPassword: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ConfirmPasswordResetMutation.Data.ResetPassword.self
      ] }

      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
