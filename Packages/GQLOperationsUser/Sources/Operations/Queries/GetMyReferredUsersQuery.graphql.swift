// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMyReferredUsersQuery: GraphQLQuery {
  public static let operationName: String = "GetMyReferredUsers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMyReferredUsers($offset: Int, $limit: Int) { referralList(offset: $offset, limit: $limit) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } counter affectedRows { __typename iInvited { __typename id username slug img visibilityStatus hasActiveReports isHiddenForUsers isfollowed isfollowing isfriend } } } }"#
    ))

  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("referralList", ReferralList.self, arguments: [
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetMyReferredUsersQuery.Data.self
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
        .field("meta", Meta.self),
        .field("counter", Int.self),
        .field("affectedRows", AffectedRows.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetMyReferredUsersQuery.Data.ReferralList.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var counter: Int { __data["counter"] }
      public var affectedRows: AffectedRows { __data["affectedRows"] }

      /// ReferralList.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String.self),
          .field("ResponseCode", String.self),
          .field("ResponseMessage", String.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetMyReferredUsersQuery.Data.ReferralList.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// ReferralList.AffectedRows
      ///
      /// Parent Type: `ReferralUsers`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ReferralUsers }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("iInvited", [IInvited].self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetMyReferredUsersQuery.Data.ReferralList.AffectedRows.self
        ] }

        public var iInvited: [IInvited] { __data["iInvited"] }

        /// ReferralList.AffectedRows.IInvited
        ///
        /// Parent Type: `ProfileUser`
        public struct IInvited: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ProfileUser }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GQLOperationsUser.ID.self),
            .field("username", String?.self),
            .field("slug", Int?.self),
            .field("img", String?.self),
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("hasActiveReports", Bool.self),
            .field("isHiddenForUsers", Bool.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
            .field("isfriend", Bool?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetMyReferredUsersQuery.Data.ReferralList.AffectedRows.IInvited.self
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var img: String? { __data["img"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
          public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
          @available(*, deprecated, message: "Use iFollowThisUser / thisUserFollowsMe")
          public var isfollowed: Bool? { __data["isfollowed"] }
          @available(*, deprecated, message: "Use iFollowThisUser / thisUserFollowsMe")
          public var isfollowing: Bool? { __data["isfollowing"] }
          public var isfriend: Bool? { __data["isfriend"] }
        }
      }
    }
  }
}
