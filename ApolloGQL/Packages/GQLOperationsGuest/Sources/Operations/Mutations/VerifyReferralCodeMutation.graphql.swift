// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class VerifyReferralCodeMutation: GraphQLMutation {
  public static let operationName: String = "VerifyReferralCode"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation VerifyReferralCode($code: String!) { verifyReferralString(referralString: $code) { __typename status ResponseCode } }"#
    ))

  public var code: String

  public init(code: String) {
    self.code = code
  }

  public var __variables: Variables? { ["code": code] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("verifyReferralString", VerifyReferralString.self, arguments: ["referralString": .variable("code")]),
    ] }

    public var verifyReferralString: VerifyReferralString { __data["verifyReferralString"] }

    /// VerifyReferralString
    ///
    /// Parent Type: `ReferralResponse`
    public struct VerifyReferralString: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.ReferralResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
