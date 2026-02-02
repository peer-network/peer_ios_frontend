// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PostInteractionsQuery: GraphQLQuery {
  public static let operationName: String = "PostInteractions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query PostInteractions($getOnly: GetOnly!, $postOrCommentId: ID!, $offset: Int, $limit: Int, $contentFilterBy: ContentFilterType) { postInteractions( getOnly: $getOnly postOrCommentId: $postOrCommentId offset: $offset limit: $limit contentFilterBy: $contentFilterBy ) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename id username slug img visibilityStatus isHiddenForUsers hasActiveReports isfollowed isfollowing isfriend } } }"#
    ))

  public var getOnly: GraphQLEnum<GetOnly>
  public var postOrCommentId: ID
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>
  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>

  public init(
    getOnly: GraphQLEnum<GetOnly>,
    postOrCommentId: ID,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>,
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  ) {
    self.getOnly = getOnly
    self.postOrCommentId = postOrCommentId
    self.offset = offset
    self.limit = limit
    self.contentFilterBy = contentFilterBy
  }

  public var __variables: Variables? { [
    "getOnly": getOnly,
    "postOrCommentId": postOrCommentId,
    "offset": offset,
    "limit": limit,
    "contentFilterBy": contentFilterBy
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("postInteractions", PostInteractions?.self, arguments: [
        "getOnly": .variable("getOnly"),
        "postOrCommentId": .variable("postOrCommentId"),
        "offset": .variable("offset"),
        "limit": .variable("limit"),
        "contentFilterBy": .variable("contentFilterBy")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PostInteractionsQuery.Data.self
    ] }

    public var postInteractions: PostInteractions? { __data["postInteractions"] }

    /// PostInteractions
    ///
    /// Parent Type: `PostInteractionResponse`
    public struct PostInteractions: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.PostInteractionResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PostInteractionsQuery.Data.PostInteractions.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// PostInteractions.Meta
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
          PostInteractionsQuery.Data.PostInteractions.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// PostInteractions.AffectedRow
      ///
      /// Parent Type: `ProfileUser`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
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
          PostInteractionsQuery.Data.PostInteractions.AffectedRow.self
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
