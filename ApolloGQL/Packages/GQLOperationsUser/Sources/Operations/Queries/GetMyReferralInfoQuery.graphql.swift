// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMyReferralInfoQuery: GraphQLQuery {
  public static let operationName: String = "GetMyReferralInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMyReferralInfo { getReferralInfo { __typename status ResponseCode referralUuid referralLink } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getReferralInfo", GetReferralInfo.self),
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("referralUuid", GQLOperationsUser.ID?.self),
        .field("referralLink", String?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var referralUuid: GQLOperationsUser.ID? { __data["referralUuid"] }
      public var referralLink: String? { __data["referralLink"] }
    }
  }
}
