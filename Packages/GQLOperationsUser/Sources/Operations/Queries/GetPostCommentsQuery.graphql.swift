// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetPostCommentsQuery: GraphQLQuery {
  public static let operationName: String = "GetPostComments"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetPostComments($contentFilterBy: ContentFilterType, $postid: ID!, $commentLimit: Int, $commentOffset: Int) { listPosts( postid: $postid commentLimit: $commentLimit commentOffset: $commentOffset contentFilterBy: $contentFilterBy ) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename amountcomments comments { __typename commentid userid postid parentid content createdat visibilityStatus hasActiveReports isHiddenForUsers amountlikes amountreplies amountreports isliked user { __typename id username slug img visibilityStatus isHiddenForUsers hasActiveReports isfollowed isfollowing isfriend } } } } }"#
    ))

  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var postid: ID
  public var commentLimit: GraphQLNullable<Int>
  public var commentOffset: GraphQLNullable<Int>

  public init(
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    postid: ID,
    commentLimit: GraphQLNullable<Int>,
    commentOffset: GraphQLNullable<Int>
  ) {
    self.contentFilterBy = contentFilterBy
    self.postid = postid
    self.commentLimit = commentLimit
    self.commentOffset = commentOffset
  }

  public var __variables: Variables? { [
    "contentFilterBy": contentFilterBy,
    "postid": postid,
    "commentLimit": commentLimit,
    "commentOffset": commentOffset
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listPosts", ListPosts.self, arguments: [
        "postid": .variable("postid"),
        "commentLimit": .variable("commentLimit"),
        "commentOffset": .variable("commentOffset"),
        "contentFilterBy": .variable("contentFilterBy")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetPostCommentsQuery.Data.self
    ] }

    public var listPosts: ListPosts { __data["listPosts"] }

    /// ListPosts
    ///
    /// Parent Type: `PostListResponse`
    public struct ListPosts: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.PostListResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetPostCommentsQuery.Data.ListPosts.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// ListPosts.Meta
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
          GetPostCommentsQuery.Data.ListPosts.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// ListPosts.AffectedRow
      ///
      /// Parent Type: `Post`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Post }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("amountcomments", Int.self),
          .field("comments", [Comment].self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetPostCommentsQuery.Data.ListPosts.AffectedRow.self
        ] }

        public var amountcomments: Int { __data["amountcomments"] }
        public var comments: [Comment] { __data["comments"] }

        /// ListPosts.AffectedRow.Comment
        ///
        /// Parent Type: `Comment`
        public struct Comment: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Comment }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("commentid", GQLOperationsUser.ID.self),
            .field("userid", GQLOperationsUser.ID.self),
            .field("postid", GQLOperationsUser.ID.self),
            .field("parentid", GQLOperationsUser.ID?.self),
            .field("content", String.self),
            .field("createdat", GQLOperationsUser.Date.self),
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("hasActiveReports", Bool.self),
            .field("isHiddenForUsers", Bool.self),
            .field("amountlikes", Int.self),
            .field("amountreplies", Int.self),
            .field("amountreports", Int.self),
            .field("isliked", Bool.self),
            .field("user", User.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetPostCommentsQuery.Data.ListPosts.AffectedRow.Comment.self
          ] }

          public var commentid: GQLOperationsUser.ID { __data["commentid"] }
          public var userid: GQLOperationsUser.ID { __data["userid"] }
          public var postid: GQLOperationsUser.ID { __data["postid"] }
          public var parentid: GQLOperationsUser.ID? { __data["parentid"] }
          public var content: String { __data["content"] }
          public var createdat: GQLOperationsUser.Date { __data["createdat"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
          public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
          public var amountlikes: Int { __data["amountlikes"] }
          public var amountreplies: Int { __data["amountreplies"] }
          public var amountreports: Int { __data["amountreports"] }
          public var isliked: Bool { __data["isliked"] }
          public var user: User { __data["user"] }

          /// ListPosts.AffectedRow.Comment.User
          ///
          /// Parent Type: `ProfileUser`
          public struct User: GQLOperationsUser.SelectionSet {
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
              GetPostCommentsQuery.Data.ListPosts.AffectedRow.Comment.User.self
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
}
