// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMyReferredUsersQuery: GraphQLQuery {
  public static let operationName: String = "GetMyReferredUsers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMyReferredUsers($offset: Int, $limit: Int) { referralList(offset: $offset, limit: $limit) { __typename status counter ResponseCode affectedRows { __typename iInvited { __typename id username slug img visibilityStatus hasActiveReports isfollowed isfollowing isfriend } } } }"#
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
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
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
          .field("iInvited", [IInvited].self),
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
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>?.self),
            .field("hasActiveReports", Bool.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
            .field("isfriend", Bool?.self),
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var img: String? { __data["img"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>? { __data["visibilityStatus"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
          public var isfollowed: Bool? { __data["isfollowed"] }
          public var isfollowing: Bool? { __data["isfollowing"] }
          public var isfriend: Bool? { __data["isfriend"] }
        }
      }
    }
  }
}
