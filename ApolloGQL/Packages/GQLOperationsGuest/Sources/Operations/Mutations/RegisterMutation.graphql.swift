// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RegisterMutation: GraphQLMutation {
  public static let operationName: String = "Register"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation Register($email: String!, $password: String!, $username: String!) { register(input: { email: $email, password: $password, username: $username }) { __typename status ResponseCode userid } }"#
    ))

  public var email: String
  public var password: String
  public var username: String

  public init(
    email: String,
    password: String,
    username: String
  ) {
    self.email = email
    self.password = password
    self.username = username
  }

  public var __variables: Variables? { [
    "email": email,
    "password": password,
    "username": username
  ] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("register", Register.self, arguments: ["input": [
        "email": .variable("email"),
        "password": .variable("password"),
        "username": .variable("username")
      ]]),
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("userid", GQLOperationsGuest.ID?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var userid: GQLOperationsGuest.ID? { __data["userid"] }
    }
  }
}
