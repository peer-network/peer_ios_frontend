// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class VerifyReferralCodeMutation: GraphQLMutation {
  public static let operationName: String = "VerifyReferralCode"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation VerifyReferralCode($code: String!) { verifyReferralString(referralString: $code) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename uid username slug img } } }"#
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
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      VerifyReferralCodeMutation.Data.self
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
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        VerifyReferralCodeMutation.Data.VerifyReferralString.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// VerifyReferralString.Meta
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
          VerifyReferralCodeMutation.Data.VerifyReferralString.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }

      /// VerifyReferralString.AffectedRows
      ///
      /// Parent Type: `ReferralInfo`
      public struct AffectedRows: GQLOperationsGuest.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.ReferralInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("uid", String?.self),
          .field("username", String?.self),
          .field("slug", String?.self),
          .field("img", String?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          VerifyReferralCodeMutation.Data.VerifyReferralString.AffectedRows.self
        ] }

        public var uid: String? { __data["uid"] }
        public var username: String? { __data["username"] }
        public var slug: String? { __data["slug"] }
        public var img: String? { __data["img"] }
      }
    }
  }
}
