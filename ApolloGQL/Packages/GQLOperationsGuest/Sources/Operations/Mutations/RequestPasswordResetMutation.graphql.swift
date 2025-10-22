// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RequestPasswordResetMutation: GraphQLMutation {
  public static let operationName: String = "RequestPasswordReset"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation RequestPasswordReset($email: String!) { requestPasswordReset(email: $email) { __typename status ResponseCode nextAttemptAt } }"#
    ))

  public var email: String

  public init(email: String) {
    self.email = email
  }

  public var __variables: Variables? { ["email": email] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("requestPasswordReset", RequestPasswordReset.self, arguments: ["email": .variable("email")]),
    ] }

    public var requestPasswordReset: RequestPasswordReset { __data["requestPasswordReset"] }

    /// RequestPasswordReset
    ///
    /// Parent Type: `ResetPasswordRequestResponse`
    public struct RequestPasswordReset: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.ResetPasswordRequestResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("nextAttemptAt", String?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var nextAttemptAt: String? { __data["nextAttemptAt"] }
    }
  }
}
