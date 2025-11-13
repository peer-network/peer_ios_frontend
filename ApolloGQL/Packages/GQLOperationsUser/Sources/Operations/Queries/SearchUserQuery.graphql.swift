// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchUserQuery: GraphQLQuery {
  public static let operationName: String = "SearchUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchUser($contentFilterBy: ContentFilterType, $userid: ID, $username: String, $offset: Int, $limit: Int) { searchUser( contentFilterBy: $contentFilterBy userid: $userid username: $username offset: $offset limit: $limit ) { __typename status counter ResponseCode affectedRows { __typename id username status slug img biography visibilityStatus hasActiveReports createdat updatedat } } }"#
    ))

  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var userid: GraphQLNullable<ID>
  public var username: GraphQLNullable<String>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    userid: GraphQLNullable<ID>,
    username: GraphQLNullable<String>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.contentFilterBy = contentFilterBy
    self.userid = userid
    self.username = username
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "contentFilterBy": contentFilterBy,
    "userid": userid,
    "username": username,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchUser", SearchUser.self, arguments: [
        "contentFilterBy": .variable("contentFilterBy"),
        "userid": .variable("userid"),
        "username": .variable("username"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    @available(*, deprecated, message: "Use listUsersV2.")
    public var searchUser: SearchUser { __data["searchUser"] }

    /// SearchUser
    ///
    /// Parent Type: `UserListResponse`
    public struct SearchUser: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserListResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// SearchUser.AffectedRow
      ///
      /// Parent Type: `User`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GQLOperationsUser.ID?.self),
          .field("username", String?.self),
          .field("status", Int?.self),
          .field("slug", Int?.self),
          .field("img", String?.self),
          .field("biography", String?.self),
          .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>?.self),
          .field("hasActiveReports", Bool.self),
          .field("createdat", GQLOperationsUser.Date?.self),
          .field("updatedat", GQLOperationsUser.Date?.self),
        ] }

        public var id: GQLOperationsUser.ID? { __data["id"] }
        public var username: String? { __data["username"] }
        public var status: Int? { __data["status"] }
        public var slug: Int? { __data["slug"] }
        public var img: String? { __data["img"] }
        public var biography: String? { __data["biography"] }
        public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>? { __data["visibilityStatus"] }
        public var hasActiveReports: Bool { __data["hasActiveReports"] }
        public var createdat: GQLOperationsUser.Date? { __data["createdat"] }
        public var updatedat: GQLOperationsUser.Date? { __data["updatedat"] }
      }
    }
  }
}
