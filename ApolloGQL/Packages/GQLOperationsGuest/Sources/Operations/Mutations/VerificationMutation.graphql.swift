// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class VerificationMutation: GraphQLMutation {
  public static let operationName: String = "Verification"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation Verification($userid: ID!) { verifyAccount(userid: $userid) { __typename status ResponseCode } }"#
    ))

  public var userid: ID

  public init(userid: ID) {
    self.userid = userid
  }

  public var __variables: Variables? { ["userid": userid] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("verifyAccount", VerifyAccount.self, arguments: ["userid": .variable("userid")]),
    ] }

    public var verifyAccount: VerifyAccount { __data["verifyAccount"] }

    /// VerifyAccount
    ///
    /// Parent Type: `DefaultResponse`
    public struct VerifyAccount: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.DefaultResponse }
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
