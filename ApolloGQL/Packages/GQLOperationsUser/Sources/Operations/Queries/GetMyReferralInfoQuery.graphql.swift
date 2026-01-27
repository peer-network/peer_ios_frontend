// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMyReferralInfoQuery: GraphQLQuery {
  public static let operationName: String = "GetMyReferralInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMyReferralInfo { getReferralInfo { __typename meta { __typename status RequestId ResponseCode ResponseMessage } referralUuid referralLink } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getReferralInfo", GetReferralInfo.self),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetMyReferralInfoQuery.Data.self
    ] }

    public var getReferralInfo: GetReferralInfo { __data["getReferralInfo"] }

    /// GetReferralInfo
    ///
    /// Parent Type: `ReferralInfoResponse`
    public struct GetReferralInfo: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ReferralInfoResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("referralUuid", GQLOperationsUser.ID?.self),
        .field("referralLink", String?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetMyReferralInfoQuery.Data.GetReferralInfo.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var referralUuid: GQLOperationsUser.ID? { __data["referralUuid"] }
      public var referralLink: String? { __data["referralLink"] }

      /// GetReferralInfo.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String?.self),
          .field("ResponseCode", String?.self),
          .field("ResponseMessage", String?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetMyReferralInfoQuery.Data.GetReferralInfo.Meta.self
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
