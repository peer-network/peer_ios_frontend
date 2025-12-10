// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class VerifyResetPasswordCodeMutation: GraphQLMutation {
  public static let operationName: String = "VerifyResetPasswordCode"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation VerifyResetPasswordCode($token: String!) { resetPasswordTokenVerify(token: $token) { __typename status RequestId ResponseCode ResponseMessage } }"#
    ))

  public var token: String

  public init(token: String) {
    self.token = token
  }

  public var __variables: Variables? { ["token": token] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("resetPasswordTokenVerify", ResetPasswordTokenVerify.self, arguments: ["token": .variable("token")]),
    ] }

    public var resetPasswordTokenVerify: ResetPasswordTokenVerify { __data["resetPasswordTokenVerify"] }

    /// ResetPasswordTokenVerify
    ///
    /// Parent Type: `DefaultResponse`
    public struct ResetPasswordTokenVerify: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("RequestId", String?.self),
        .field("ResponseCode", String.self),
        .field("ResponseMessage", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var requestId: String? { __data["RequestId"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var responseMessage: String? { __data["ResponseMessage"] }
    }
  }
}
