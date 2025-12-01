// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateMailMutation: GraphQLMutation {
  public static let operationName: String = "UpdateMail"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateMail($email: String!, $password: String!) { updateEmail(email: $email, password: $password) { __typename status ResponseCode } }"#
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

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateEmail", UpdateEmail.self, arguments: [
        "email": .variable("email"),
        "password": .variable("password")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdateMailMutation.Data.self
    ] }

    public var updateEmail: UpdateEmail { __data["updateEmail"] }

    /// UpdateEmail
    ///
    /// Parent Type: `DefaultResponse`
    public struct UpdateEmail: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateMailMutation.Data.UpdateEmail.self
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
