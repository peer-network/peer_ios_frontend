// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreatePostMutation: GraphQLMutation {
  public static let operationName: String = "CreatePost"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreatePost($contentType: ContentType!, $title: String!, $media: [String!], $mediadescription: String, $tags: [String!], $cover: [String!]) { createPost( action: POST input: { contenttype: $contentType title: $title media: $media mediadescription: $mediadescription tags: $tags cover: $cover } ) { __typename status ResponseCode affectedRows { __typename id contenttype title media cover mediadescription createdat amountlikes amountviews amountcomments amountdislikes amounttrending isliked isviewed isreported isdisliked issaved tags url user { __typename id username slug img isfollowed isfollowing } } } }"#
    ))

  public var contentType: GraphQLEnum<ContentType>
  public var title: String
  public var media: GraphQLNullable<[String]>
  public var mediadescription: GraphQLNullable<String>
  public var tags: GraphQLNullable<[String]>
  public var cover: GraphQLNullable<[String]>

  public init(
    contentType: GraphQLEnum<ContentType>,
    title: String,
    media: GraphQLNullable<[String]>,
    mediadescription: GraphQLNullable<String>,
    tags: GraphQLNullable<[String]>,
    cover: GraphQLNullable<[String]>
  ) {
    self.contentType = contentType
    self.title = title
    self.media = media
    self.mediadescription = mediadescription
    self.tags = tags
    self.cover = cover
  }

  public var __variables: Variables? { [
    "contentType": contentType,
    "title": title,
    "media": media,
    "mediadescription": mediadescription,
    "tags": tags,
    "cover": cover
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createPost", CreatePost.self, arguments: [
        "action": "POST",
        "input": [
          "contenttype": .variable("contentType"),
          "title": .variable("title"),
          "media": .variable("media"),
          "mediadescription": .variable("mediadescription"),
          "tags": .variable("tags"),
          "cover": .variable("cover")
        ]
      ]),
    ] }

    public var createPost: CreatePost { __data["createPost"] }

    /// CreatePost
    ///
    /// Parent Type: `PostResponse`
    public struct CreatePost: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.PostResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// CreatePost.AffectedRows
      ///
      /// Parent Type: `Post`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Post }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GQLOperationsUser.ID.self),
          .field("contenttype", String.self),
          .field("title", String.self),
          .field("media", String.self),
          .field("cover", String.self),
          .field("mediadescription", String.self),
          .field("createdat", GQLOperationsUser.Date.self),
          .field("amountlikes", Int.self),
          .field("amountviews", Int.self),
          .field("amountcomments", Int.self),
          .field("amountdislikes", Int.self),
          .field("amounttrending", Int.self),
          .field("isliked", Bool.self),
          .field("isviewed", Bool.self),
          .field("isreported", Bool.self),
          .field("isdisliked", Bool.self),
          .field("issaved", Bool.self),
          .field("tags", [String?].self),
          .field("url", String.self),
          .field("user", User.self),
        ] }

        public var id: GQLOperationsUser.ID { __data["id"] }
        public var contenttype: String { __data["contenttype"] }
        public var title: String { __data["title"] }
        public var media: String { __data["media"] }
        public var cover: String { __data["cover"] }
        public var mediadescription: String { __data["mediadescription"] }
        public var createdat: GQLOperationsUser.Date { __data["createdat"] }
        public var amountlikes: Int { __data["amountlikes"] }
        public var amountviews: Int { __data["amountviews"] }
        public var amountcomments: Int { __data["amountcomments"] }
        public var amountdislikes: Int { __data["amountdislikes"] }
        public var amounttrending: Int { __data["amounttrending"] }
        public var isliked: Bool { __data["isliked"] }
        public var isviewed: Bool { __data["isviewed"] }
        public var isreported: Bool { __data["isreported"] }
        public var isdisliked: Bool { __data["isdisliked"] }
        public var issaved: Bool { __data["issaved"] }
        public var tags: [String?] { __data["tags"] }
        public var url: String { __data["url"] }
        public var user: User { __data["user"] }

        /// CreatePost.AffectedRows.User
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
