// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateCommentMutation: GraphQLMutation {
  public static let operationName: String = "CreateComment"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateComment($postid: ID!, $parentid: ID, $content: String!) { createComment( action: COMMENT postid: $postid parentid: $parentid content: $content ) { __typename status ResponseCode affectedRows { __typename commentid userid postid parentid content createdat amountlikes isliked user { __typename id username slug img isfollowed isfollowing } } } }"#
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

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
          .field("amountlikes", Int.self),
          .field("isliked", Bool.self),
          .field("user", User.self),
        ] }

        public var commentid: GQLOperationsUser.ID { __data["commentid"] }
        public var userid: GQLOperationsUser.ID { __data["userid"] }
        public var postid: GQLOperationsUser.ID { __data["postid"] }
        public var parentid: GQLOperationsUser.ID? { __data["parentid"] }
        public var content: String { __data["content"] }
        public var createdat: GQLOperationsUser.Date { __data["createdat"] }
        public var amountlikes: Int { __data["amountlikes"] }
        public var isliked: Bool { __data["isliked"] }
        public var user: User { __data["user"] }

        /// CreateComment.AffectedRow.User
        ///
        /// Parent Type: `ProfilUser`
        public struct User: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ProfilUser }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GQLOperationsUser.ID.self),
            .field("username", String?.self),
            .field("slug", Int?.self),
            .field("img", String?.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var img: String? { __data["img"] }
          public var isfollowed: Bool? { __data["isfollowed"] }
          public var isfollowing: Bool? { __data["isfollowing"] }
        }
      }
    }
  }
}
