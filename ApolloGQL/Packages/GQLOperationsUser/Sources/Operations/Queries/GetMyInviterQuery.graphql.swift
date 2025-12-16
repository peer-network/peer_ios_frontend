// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMyInviterQuery: GraphQLQuery {
  public static let operationName: String = "GetMyInviter"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMyInviter { referralList { __typename status ResponseCode affectedRows { __typename invitedBy { __typename id username slug img isfollowed isfollowing } } } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("referralList", ReferralList.self),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetMyInviterQuery.Data.self
    ] }

    public var referralList: ReferralList { __data["referralList"] }

    /// ReferralList
    ///
    /// Parent Type: `ReferralListResponse`
    public struct ReferralList: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ReferralListResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetMyInviterQuery.Data.ReferralList.self
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows { __data["affectedRows"] }

      /// ReferralList.AffectedRows
      ///
      /// Parent Type: `ReferralUsers`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ReferralUsers }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("invitedBy", InvitedBy?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetMyInviterQuery.Data.ReferralList.AffectedRows.self
        ] }

        public var invitedBy: InvitedBy? { __data["invitedBy"] }

        /// ReferralList.AffectedRows.InvitedBy
        ///
        /// Parent Type: `ProfileUser`
        public struct InvitedBy: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ProfileUser }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GQLOperationsUser.ID.self),
            .field("username", String?.self),
            .field("slug", Int?.self),
            .field("img", String?.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetMyInviterQuery.Data.ReferralList.AffectedRows.InvitedBy.self
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var img: String? { __data["img"] }
          @available(*, deprecated, message: "Use iFollowThisUser / thisUserFollowsMe")
          public var isfollowed: Bool? { __data["isfollowed"] }
          @available(*, deprecated, message: "Use iFollowThisUser / thisUserFollowsMe")
          public var isfollowing: Bool? { __data["isfollowing"] }
        }
      }
    }
  }
}
