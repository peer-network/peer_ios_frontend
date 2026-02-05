// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFollowersQuery: GraphQLQuery {
  public static let operationName: String = "GetFollowers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFollowers($contentFilterBy: ContentFilterType, $userid: ID, $offset: Int, $limit: Int) { listFollowRelations( contentFilterBy: $contentFilterBy userid: $userid offset: $offset limit: $limit ) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename followers { __typename id username slug img visibilityStatus isHiddenForUsers hasActiveReports isfollowed isfollowing isfriend } } } }"#
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
      .field("listFollowRelations", ListFollowRelations.self, arguments: [
        "contentFilterBy": .variable("contentFilterBy"),
        "userid": .variable("userid"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetFollowersQuery.Data.self
    ] }

    public var listFollowRelations: ListFollowRelations { __data["listFollowRelations"] }

    /// ListFollowRelations
    ///
    /// Parent Type: `FollowRelationsResponse`
    public struct ListFollowRelations: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.FollowRelationsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetFollowersQuery.Data.ListFollowRelations.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// ListFollowRelations.Meta
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
          GetFollowersQuery.Data.ListFollowRelations.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// ListFollowRelations.AffectedRows
      ///
      /// Parent Type: `FollowRelations`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.FollowRelations }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("followers", [Follower]?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetFollowersQuery.Data.ListFollowRelations.AffectedRows.self
        ] }

        public var followers: [Follower]? { __data["followers"] }

        /// ListFollowRelations.AffectedRows.Follower
        ///
        /// Parent Type: `ProfileUser`
        public struct Follower: GQLOperationsUser.SelectionSet {
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
            .field("isHiddenForUsers", Bool.self),
            .field("hasActiveReports", Bool.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
            .field("isfriend", Bool?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetFollowersQuery.Data.ListFollowRelations.AffectedRows.Follower.self
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var img: String? { __data["img"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
          public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
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
