// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFriendsQuery: GraphQLQuery {
  public static let operationName: String = "GetFriends"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFriends($contentFilterBy: ContentFilterType, $userid: ID, $offset: Int, $limit: Int) { listFriends( contentFilterBy: $contentFilterBy userid: $userid offset: $offset limit: $limit ) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename userid img username slug biography visibilityStatus isHiddenForUsers hasActiveReports updatedat } } }"#
    ))

  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var userid: GraphQLNullable<ID>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    userid: GraphQLNullable<ID>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.contentFilterBy = contentFilterBy
    self.userid = userid
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "contentFilterBy": contentFilterBy,
    "userid": userid,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listFriends", ListFriends.self, arguments: [
        "contentFilterBy": .variable("contentFilterBy"),
        "userid": .variable("userid"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetFriendsQuery.Data.self
    ] }

    public var listFriends: ListFriends { __data["listFriends"] }

    /// ListFriends
    ///
    /// Parent Type: `UserFriendsResponse`
    public struct ListFriends: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserFriendsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetFriendsQuery.Data.ListFriends.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// ListFriends.Meta
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
          GetFriendsQuery.Data.ListFriends.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// ListFriends.AffectedRow
      ///
      /// Parent Type: `BasicUserInfo`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.BasicUserInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userid", GQLOperationsUser.ID?.self),
          .field("img", String?.self),
          .field("username", String?.self),
          .field("slug", Int?.self),
          .field("biography", String?.self),
          .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
          .field("isHiddenForUsers", Bool.self),
          .field("hasActiveReports", Bool.self),
          .field("updatedat", GQLOperationsUser.Date.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetFriendsQuery.Data.ListFriends.AffectedRow.self
        ] }

        public var userid: GQLOperationsUser.ID? { __data["userid"] }
        public var img: String? { __data["img"] }
        public var username: String? { __data["username"] }
        public var slug: Int? { __data["slug"] }
        public var biography: String? { __data["biography"] }
        public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
        public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
        public var hasActiveReports: Bool { __data["hasActiveReports"] }
        public var updatedat: GQLOperationsUser.Date { __data["updatedat"] }
      }
    }
  }
}
