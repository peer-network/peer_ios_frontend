// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetPostCommentsQuery: GraphQLQuery {
  public static let operationName: String = "GetPostComments"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetPostComments($postid: ID!, $commentLimit: Int, $commentOffset: Int) { getallposts( postid: $postid commentLimit: $commentLimit commentOffset: $commentOffset ) { __typename status ResponseCode affectedRows { __typename amountcomments comments { __typename commentid userid postid parentid content amountlikes isliked createdat user { __typename id username slug img isfollowed isfollowing } } } } }"#
    ))

  public var postid: ID
  public var commentLimit: GraphQLNullable<Int>
  public var commentOffset: GraphQLNullable<Int>

  public init(
    postid: ID,
    commentLimit: GraphQLNullable<Int>,
    commentOffset: GraphQLNullable<Int>
  ) {
    self.postid = postid
    self.commentLimit = commentLimit
    self.commentOffset = commentOffset
  }

  public var __variables: Variables? { [
    "postid": postid,
    "commentLimit": commentLimit,
    "commentOffset": commentOffset
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getallposts", Getallposts.self, arguments: [
        "postid": .variable("postid"),
        "commentLimit": .variable("commentLimit"),
        "commentOffset": .variable("commentOffset")
      ]),
    ] }

    public var getallposts: Getallposts { __data["getallposts"] }

    /// Getallposts
    ///
    /// Parent Type: `GetAllPostResponse`
    public struct Getallposts: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.GetAllPostResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// Getallposts.AffectedRow
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

        public var amountcomments: Int { __data["amountcomments"] }
        public var comments: [Comment] { __data["comments"] }

        /// Getallposts.AffectedRow.Comment
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
            .field("amountlikes", Int.self),
            .field("isliked", Bool.self),
            .field("createdat", GQLOperationsUser.Date.self),
            .field("user", User.self),
          ] }

          public var commentid: GQLOperationsUser.ID { __data["commentid"] }
          public var userid: GQLOperationsUser.ID { __data["userid"] }
          public var postid: GQLOperationsUser.ID { __data["postid"] }
          public var parentid: GQLOperationsUser.ID? { __data["parentid"] }
          public var content: String { __data["content"] }
          public var amountlikes: Int { __data["amountlikes"] }
          public var isliked: Bool { __data["isliked"] }
          public var createdat: GQLOperationsUser.Date { __data["createdat"] }
          public var user: User { __data["user"] }

          /// Getallposts.AffectedRow.Comment.User
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
}
