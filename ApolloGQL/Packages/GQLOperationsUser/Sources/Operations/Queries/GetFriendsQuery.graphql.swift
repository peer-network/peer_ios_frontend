// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFriendsQuery: GraphQLQuery {
  public static let operationName: String = "GetFriends"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFriends($contentFilterBy: ContentFilterType, $offset: Int, $limit: Int) { listFriends(contentFilterBy: $contentFilterBy, offset: $offset, limit: $limit) { __typename status ResponseCode affectedRows { __typename userid img username slug } } }"#
    ))

  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.contentFilterBy = contentFilterBy
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "contentFilterBy": contentFilterBy,
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetFriendsQuery.Data.ListFriends.self
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

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
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetFriendsQuery.Data.ListFriends.AffectedRow.self
        ] }

        public var userid: GQLOperationsUser.ID? { __data["userid"] }
        public var img: String? { __data["img"] }
        public var username: String? { __data["username"] }
        public var slug: Int? { __data["slug"] }
      }
    }
  }
}
