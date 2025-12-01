// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllPostsQuery: GraphQLQuery {
  public static let operationName: String = "GetAllPosts"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetAllPosts($filterBy: [PostFilterType!], $contentFilterBy: ContentFilterType, $ignoreOption: IgnoreOption, $sortBy: PostSortType, $title: String, $tag: String, $from: Date, $to: Date, $offset: Int, $limit: Int, $commentOffset: Int, $commentLimit: Int, $postid: ID, $userid: ID) { listPosts( filterBy: $filterBy contentFilterBy: $contentFilterBy IgnorList: $ignoreOption commentLimit: $commentLimit commentOffset: $commentOffset limit: $limit offset: $offset to: $to from: $from tag: $tag title: $title sortBy: $sortBy postid: $postid userid: $userid ) { __typename status ResponseCode affectedRows { __typename id contenttype title media cover mediadescription createdat amountlikes amountviews amountcomments amountdislikes amounttrending isliked isviewed isreported isdisliked issaved tags url user { __typename id username slug img isfollowed isfollowing } } } }"#
    ))

  public var filterBy: GraphQLNullable<[GraphQLEnum<PostFilterType>]>
  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var ignoreOption: GraphQLNullable<GraphQLEnum<IgnoreOption>>
  public var sortBy: GraphQLNullable<GraphQLEnum<PostSortType>>
  public var title: GraphQLNullable<String>
  public var tag: GraphQLNullable<String>
  public var from: GraphQLNullable<Date>
  public var to: GraphQLNullable<Date>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>
  public var commentOffset: GraphQLNullable<Int>
  public var commentLimit: GraphQLNullable<Int>
  public var postid: GraphQLNullable<ID>
  public var userid: GraphQLNullable<ID>

  public init(
    filterBy: GraphQLNullable<[GraphQLEnum<PostFilterType>]>,
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    ignoreOption: GraphQLNullable<GraphQLEnum<IgnoreOption>>,
    sortBy: GraphQLNullable<GraphQLEnum<PostSortType>>,
    title: GraphQLNullable<String>,
    tag: GraphQLNullable<String>,
    from: GraphQLNullable<Date>,
    to: GraphQLNullable<Date>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>,
    commentOffset: GraphQLNullable<Int>,
    commentLimit: GraphQLNullable<Int>,
    postid: GraphQLNullable<ID>,
    userid: GraphQLNullable<ID>
  ) {
    self.filterBy = filterBy
    self.contentFilterBy = contentFilterBy
    self.ignoreOption = ignoreOption
    self.sortBy = sortBy
    self.title = title
    self.tag = tag
    self.from = from
    self.to = to
    self.offset = offset
    self.limit = limit
    self.commentOffset = commentOffset
    self.commentLimit = commentLimit
    self.postid = postid
    self.userid = userid
  }

  public var __variables: Variables? { [
    "filterBy": filterBy,
    "contentFilterBy": contentFilterBy,
    "ignoreOption": ignoreOption,
    "sortBy": sortBy,
    "title": title,
    "tag": tag,
    "from": from,
    "to": to,
    "offset": offset,
    "limit": limit,
    "commentOffset": commentOffset,
    "commentLimit": commentLimit,
    "postid": postid,
    "userid": userid
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listPosts", ListPosts.self, arguments: [
        "filterBy": .variable("filterBy"),
        "contentFilterBy": .variable("contentFilterBy"),
        "IgnorList": .variable("ignoreOption"),
        "commentLimit": .variable("commentLimit"),
        "commentOffset": .variable("commentOffset"),
        "limit": .variable("limit"),
        "offset": .variable("offset"),
        "to": .variable("to"),
        "from": .variable("from"),
        "tag": .variable("tag"),
        "title": .variable("title"),
        "sortBy": .variable("sortBy"),
        "postid": .variable("postid"),
        "userid": .variable("userid")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetAllPostsQuery.Data.self
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetAllPostsQuery.Data.ListPosts.self
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// ListPosts.AffectedRow
      ///
      /// Parent Type: `Post`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
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
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetAllPostsQuery.Data.ListPosts.AffectedRow.self
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

        /// ListPosts.AffectedRow.User
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
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetAllPostsQuery.Data.ListPosts.AffectedRow.User.self
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
