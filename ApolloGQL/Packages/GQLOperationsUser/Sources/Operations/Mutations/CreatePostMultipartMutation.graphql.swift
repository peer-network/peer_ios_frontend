// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreatePostMultipartMutation: GraphQLMutation {
  public static let operationName: String = "CreatePostMultipart"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreatePostMultipart($contentType: ContentType!, $title: String!, $uploadedFiles: String!, $mediadescription: String, $tags: [String!], $cover: [String!]) { createPost( action: POST input: { contenttype: $contentType title: $title uploadedFiles: $uploadedFiles mediadescription: $mediadescription tags: $tags cover: $cover } ) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename id contenttype title media cover mediadescription createdat visibilityStatus isHiddenForUsers hasActiveReports amountreports amountlikes amountviews amountcomments amountdislikes amounttrending isliked isviewed isreported isdisliked issaved tags url user { __typename id username slug img visibilityStatus isHiddenForUsers hasActiveReports isfollowed isfollowing isfriend } } } }"#
    ))

  public var contentType: GraphQLEnum<ContentType>
  public var title: String
  public var uploadedFiles: String
  public var mediadescription: GraphQLNullable<String>
  public var tags: GraphQLNullable<[String]>
  public var cover: GraphQLNullable<[String]>

  public init(
    contentType: GraphQLEnum<ContentType>,
    title: String,
    uploadedFiles: String,
    mediadescription: GraphQLNullable<String>,
    tags: GraphQLNullable<[String]>,
    cover: GraphQLNullable<[String]>
  ) {
    self.contentType = contentType
    self.title = title
    self.uploadedFiles = uploadedFiles
    self.mediadescription = mediadescription
    self.tags = tags
    self.cover = cover
  }

  public var __variables: Variables? { [
    "contentType": contentType,
    "title": title,
    "uploadedFiles": uploadedFiles,
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
          "uploadedFiles": .variable("uploadedFiles"),
          "mediadescription": .variable("mediadescription"),
          "tags": .variable("tags"),
          "cover": .variable("cover")
        ]
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CreatePostMultipartMutation.Data.self
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
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreatePostMultipartMutation.Data.CreatePost.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// CreatePost.Meta
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
          CreatePostMultipartMutation.Data.CreatePost.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }

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
          .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
          .field("isHiddenForUsers", Bool.self),
          .field("hasActiveReports", Bool.self),
          .field("amountreports", Int.self),
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
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreatePostMultipartMutation.Data.CreatePost.AffectedRows.self
        ] }

        public var id: GQLOperationsUser.ID { __data["id"] }
        public var contenttype: String { __data["contenttype"] }
        public var title: String { __data["title"] }
        public var media: String { __data["media"] }
        public var cover: String { __data["cover"] }
        public var mediadescription: String { __data["mediadescription"] }
        public var createdat: GQLOperationsUser.Date { __data["createdat"] }
        public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
        public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
        public var hasActiveReports: Bool { __data["hasActiveReports"] }
        public var amountreports: Int { __data["amountreports"] }
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
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("isHiddenForUsers", Bool.self),
            .field("hasActiveReports", Bool.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
            .field("isfriend", Bool?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            CreatePostMultipartMutation.Data.CreatePost.AffectedRows.User.self
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
