// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteAccountMutation: GraphQLMutation {
  public static let operationName: String = "DeleteAccount"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteAccount($password: String!) { deleteAccount(password: $password) { __typename status ResponseCode } }"#
    ))

  public var password: String

  public init(password: String) {
    self.password = password
  }

  public var __variables: Variables? { ["password": password] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteAccount", DeleteAccount.self, arguments: ["password": .variable("password")]),
    ] }

    public var deleteAccount: DeleteAccount { __data["deleteAccount"] }

    /// DeleteAccount
    ///
    /// Parent Type: `DefaultResponse`
    public struct DeleteAccount: GQLOperationsUser.SelectionSet {
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
