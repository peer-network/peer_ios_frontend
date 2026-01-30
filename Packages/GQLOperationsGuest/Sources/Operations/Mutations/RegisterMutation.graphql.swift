// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RegisterMutation: GraphQLMutation {
  public static let operationName: String = "Register"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation Register($email: String!, $password: String!, $username: String!, $referralUuid: ID!) { register( input: { email: $email password: $password username: $username referralUuid: $referralUuid } ) { __typename userid meta { __typename status RequestId ResponseCode ResponseMessage } } }"#
    ))

  public var email: String
  public var password: String
  public var username: String
  public var referralUuid: ID

  public init(
    email: String,
    password: String,
    username: String,
    referralUuid: ID
  ) {
    self.email = email
    self.password = password
    self.username = username
    self.referralUuid = referralUuid
  }

  public var __variables: Variables? { [
    "email": email,
    "password": password,
    "username": username,
    "referralUuid": referralUuid
  ] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("register", Register.self, arguments: ["input": [
        "email": .variable("email"),
        "password": .variable("password"),
        "username": .variable("username"),
        "referralUuid": .variable("referralUuid")
      ]]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      RegisterMutation.Data.self
    ] }

    public var register: Register { __data["register"] }

    /// Register
    ///
    /// Parent Type: `RegisterResponse`
    public struct Register: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.RegisterResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("userid", GQLOperationsGuest.ID?.self),
        .field("meta", Meta.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RegisterMutation.Data.Register.self
      ] }

      public var userid: GQLOperationsGuest.ID? { __data["userid"] }
      public var meta: Meta { __data["meta"] }

      /// Register.Meta
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
          RegisterMutation.Data.Register.Meta.self
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
