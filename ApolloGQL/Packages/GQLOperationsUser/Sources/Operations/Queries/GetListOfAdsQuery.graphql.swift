// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetListOfAdsQuery: GraphQLQuery {
  public static let operationName: String = "GetListOfAds"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetListOfAds($userID: ID, $filterBy: [ContentType!], $offset: Int, $limit: Int) { listAdvertisementPosts( userid: $userID filterBy: $filterBy offset: $offset limit: $limit ) { __typename status ResponseCode counter affectedRows { __typename advertisement { __typename advertisementid postid advertisementtype startdate enddate createdat user { __typename id username slug img isfollowed isfollowing isfriend } } post { __typename id contenttype title media cover mediadescription createdat amountlikes amountviews amountcomments amountdislikes amounttrending isliked isviewed isreported isdisliked issaved tags url user { __typename id username slug img isfollowed isfollowing isfriend } } } } }"#
    ))

  public var userID: GraphQLNullable<ID>
  public var filterBy: GraphQLNullable<[GraphQLEnum<ContentType>]>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    userID: GraphQLNullable<ID>,
    filterBy: GraphQLNullable<[GraphQLEnum<ContentType>]>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.userID = userID
    self.filterBy = filterBy
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "userID": userID,
    "filterBy": filterBy,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listAdvertisementPosts", ListAdvertisementPosts.self, arguments: [
        "userid": .variable("userID"),
        "filterBy": .variable("filterBy"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var listAdvertisementPosts: ListAdvertisementPosts { __data["listAdvertisementPosts"] }

    /// ListAdvertisementPosts
    ///
    /// Parent Type: `ListAdvertisementPostsResponse`
    public struct ListAdvertisementPosts: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ListAdvertisementPostsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("counter", Int.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var counter: Int { __data["counter"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// ListAdvertisementPosts.AffectedRow
      ///
      /// Parent Type: `AdvertisementPost`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AdvertisementPost }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("advertisement", Advertisement.self),
          .field("post", Post.self),
        ] }

        public var advertisement: Advertisement { __data["advertisement"] }
        public var post: Post { __data["post"] }

        /// ListAdvertisementPosts.AffectedRow.Advertisement
        ///
        /// Parent Type: `AdvCreator`
        public struct Advertisement: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AdvCreator }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("advertisementid", GQLOperationsUser.ID.self),
            .field("postid", GQLOperationsUser.ID.self),
            .field("advertisementtype", GraphQLEnum<GQLOperationsUser.AdvertisementType>.self),
            .field("startdate", GQLOperationsUser.Date.self),
            .field("enddate", GQLOperationsUser.Date.self),
            .field("createdat", GQLOperationsUser.Date.self),
            .field("user", User.self),
          ] }

          public var advertisementid: GQLOperationsUser.ID { __data["advertisementid"] }
          public var postid: GQLOperationsUser.ID { __data["postid"] }
          public var advertisementtype: GraphQLEnum<GQLOperationsUser.AdvertisementType> { __data["advertisementtype"] }
          public var startdate: GQLOperationsUser.Date { __data["startdate"] }
          public var enddate: GQLOperationsUser.Date { __data["enddate"] }
          public var createdat: GQLOperationsUser.Date { __data["createdat"] }
          public var user: User { __data["user"] }

          /// ListAdvertisementPosts.AffectedRow.Advertisement.User
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
              .field("isfriend", Bool?.self),
            ] }

            public var id: GQLOperationsUser.ID { __data["id"] }
            public var username: String? { __data["username"] }
            public var slug: Int? { __data["slug"] }
            public var img: String? { __data["img"] }
            public var isfollowed: Bool? { __data["isfollowed"] }
            public var isfollowing: Bool? { __data["isfollowing"] }
            public var isfriend: Bool? { __data["isfriend"] }
          }
        }

        /// ListAdvertisementPosts.AffectedRow.Post
        ///
        /// Parent Type: `Post`
        public struct Post: GQLOperationsUser.SelectionSet {
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

          /// ListAdvertisementPosts.AffectedRow.Post.User
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
              .field("isfriend", Bool?.self),
            ] }

            public var id: GQLOperationsUser.ID { __data["id"] }
            public var username: String? { __data["username"] }
            public var slug: Int? { __data["slug"] }
            public var img: String? { __data["img"] }
            public var isfollowed: Bool? { __data["isfollowed"] }
            public var isfollowing: Bool? { __data["isfollowing"] }
            public var isfriend: Bool? { __data["isfriend"] }
          }
        }
      }
    }
  }
}
