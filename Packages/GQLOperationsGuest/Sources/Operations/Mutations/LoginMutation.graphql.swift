// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LoginMutation: GraphQLMutation {
  public static let operationName: String = "Login"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation Login($email: String!, $password: String!) { login(email: $email, password: $password) { __typename accessToken refreshToken meta { __typename status RequestId ResponseCode ResponseMessage } } }"#
    ))

  public var email: String
  public var password: String

  public init(
    email: String,
    password: String
  ) {
    self.email = email
    self.password = password
  }

  public var __variables: Variables? { [
    "email": email,
    "password": password
  ] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("login", Login.self, arguments: [
        "email": .variable("email"),
        "password": .variable("password")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      LoginMutation.Data.self
    ] }

    public var login: Login { __data["login"] }

    /// Login
    ///
    /// Parent Type: `AuthPayload`
    public struct Login: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.AuthPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("accessToken", String?.self),
        .field("refreshToken", String?.self),
        .field("meta", Meta.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        LoginMutation.Data.Login.self
      ] }

      public var accessToken: String? { __data["accessToken"] }
      public var refreshToken: String? { __data["refreshToken"] }
      public var meta: Meta { __data["meta"] }

      /// Login.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsGuest.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String?.self),
          .field("ResponseCode", String?.self),
          .field("ResponseMessage", String?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          LoginMutation.Data.Login.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }
    }
  }
}
