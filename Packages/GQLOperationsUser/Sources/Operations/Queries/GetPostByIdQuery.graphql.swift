// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetPostByIdQuery: GraphQLQuery {
  public static let operationName: String = "GetPostById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetPostById($postid: ID!) { listPosts(postid: $postid, contentFilterBy: MYGRANDMAHATES) { __typename status counter ResponseCode affectedRows { __typename id contenttype title media cover mediadescription createdat visibilityStatus isHiddenForUsers hasActiveReports amountlikes amountviews amountcomments amountdislikes amounttrending isliked isviewed isreported isdisliked issaved tags url user { __typename id username slug img visibilityStatus hasActiveReports isHiddenForUsers isfollowed isfollowing isfriend } } } }"#
    ))

  public var postid: ID

  public init(postid: ID) {
    self.postid = postid
  }

  public var __variables: Variables? { ["postid": postid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listPosts", ListPosts.self, arguments: [
        "postid": .variable("postid"),
        "contentFilterBy": "MYGRANDMAHATES"
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetPostByIdQuery.Data.self
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
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetPostByIdQuery.Data.ListPosts.self
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
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
          .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
          .field("isHiddenForUsers", Bool.self),
          .field("hasActiveReports", Bool.self),
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
          GetPostByIdQuery.Data.ListPosts.AffectedRow.self
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
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("hasActiveReports", Bool.self),
            .field("isHiddenForUsers", Bool.self),
            .field("isfollowed", Bool?.self),
            .field("isfollowing", Bool?.self),
            .field("isfriend", Bool?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetPostByIdQuery.Data.ListPosts.AffectedRow.User.self
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
