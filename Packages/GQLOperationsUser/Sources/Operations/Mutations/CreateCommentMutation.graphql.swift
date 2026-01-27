// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateCommentMutation: GraphQLMutation {
  public static let operationName: String = "CreateComment"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateComment($postid: ID!, $parentid: ID, $content: String!) { createComment( action: COMMENT postid: $postid parentid: $parentid content: $content ) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename commentid userid postid parentid content createdat visibilityStatus hasActiveReports isHiddenForUsers amountlikes amountreplies amountreports isliked user { __typename id username slug img visibilityStatus hasActiveReports isHiddenForUsers isfollowed isfollowing isfriend } } } }"#
    ))

  public var postid: ID
  public var parentid: GraphQLNullable<ID>
  public var content: String

  public init(
    postid: ID,
    parentid: GraphQLNullable<ID>,
    content: String
  ) {
    self.postid = postid
    self.parentid = parentid
    self.content = content
  }

  public var __variables: Variables? { [
    "postid": postid,
    "parentid": parentid,
    "content": content
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createComment", CreateComment.self, arguments: [
        "action": "COMMENT",
        "postid": .variable("postid"),
        "parentid": .variable("parentid"),
        "content": .variable("content")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CreateCommentMutation.Data.self
    ] }

    public var createComment: CreateComment { __data["createComment"] }

    /// CreateComment
    ///
    /// Parent Type: `CommentResponse`
    public struct CreateComment: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.CommentResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateCommentMutation.Data.CreateComment.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// CreateComment.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String?.self),
          .field("ResponseCode", String?.self),
          .field("ResponseMessage", String?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreateCommentMutation.Data.CreateComment.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }

      /// CreateComment.AffectedRow
      ///
      /// Parent Type: `Comment`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
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
          CreateCommentMutation.Data.CreateComment.AffectedRow.self
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

        /// CreateComment.AffectedRow.User
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
            .field("hasActiveReports", Bool.self),
            .field("isHiddenForUsers", Bool.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
            .field("isfriend", Bool?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            CreateCommentMutation.Data.CreateComment.AffectedRow.User.self
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
