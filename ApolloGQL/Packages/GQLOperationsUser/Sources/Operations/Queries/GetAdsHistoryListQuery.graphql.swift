// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAdsHistoryListQuery: GraphQLQuery {
  public static let operationName: String = "GetAdsHistoryList"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetAdsHistoryList($userId: ID, $offset: Int, $limit: Int) { advertisementHistory( filter: { userId: $userId } sort: NEWEST offset: $offset limit: $limit ) { __typename status ResponseCode affectedRows { __typename advertisements { __typename id createdAt type timeframeStart timeframeEnd totalTokenCost totalEuroCost gemsEarned amountLikes amountViews amountComments amountDislikes amountReports post { __typename id contenttype title media cover mediadescription createdat visibilityStatus hasActiveReports amountlikes amountviews amountcomments amountdislikes amounttrending isliked isviewed isreported isdisliked issaved tags url user { __typename id username slug img isfollowed isfollowing isfriend visibilityStatus hasActiveReports } } user { __typename id username slug img isfollowed isfollowing isfriend visibilityStatus hasActiveReports } } } } }"#
    ))

  public var userId: GraphQLNullable<ID>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    userId: GraphQLNullable<ID>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.userId = userId
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "userId": userId,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("advertisementHistory", AdvertisementHistory.self, arguments: [
        "filter": ["userId": .variable("userId")],
        "sort": "NEWEST",
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var advertisementHistory: AdvertisementHistory { __data["advertisementHistory"] }

    /// AdvertisementHistory
    ///
    /// Parent Type: `ListedAdvertisementData`
    public struct AdvertisementHistory: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ListedAdvertisementData }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// AdvertisementHistory.AffectedRows
      ///
      /// Parent Type: `AdvertisementHistoryResult`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AdvertisementHistoryResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("advertisements", [Advertisement?]?.self),
        ] }

        public var advertisements: [Advertisement?]? { __data["advertisements"] }

        /// AdvertisementHistory.AffectedRows.Advertisement
        ///
        /// Parent Type: `Advertisement`
        public struct Advertisement: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Advertisement }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GQLOperationsUser.ID.self),
            .field("createdAt", GQLOperationsUser.Date.self),
            .field("type", GraphQLEnum<GQLOperationsUser.AdvertisementType>.self),
            .field("timeframeStart", GQLOperationsUser.Date.self),
            .field("timeframeEnd", GQLOperationsUser.Date.self),
            .field("totalTokenCost", Double.self),
            .field("totalEuroCost", Double.self),
            .field("gemsEarned", Double.self),
            .field("amountLikes", Int.self),
            .field("amountViews", Int.self),
            .field("amountComments", Int.self),
            .field("amountDislikes", Int.self),
            .field("amountReports", Int.self),
            .field("post", Post.self),
            .field("user", User.self),
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var createdAt: GQLOperationsUser.Date { __data["createdAt"] }
          public var type: GraphQLEnum<GQLOperationsUser.AdvertisementType> { __data["type"] }
          public var timeframeStart: GQLOperationsUser.Date { __data["timeframeStart"] }
          public var timeframeEnd: GQLOperationsUser.Date { __data["timeframeEnd"] }
          public var totalTokenCost: Double { __data["totalTokenCost"] }
          public var totalEuroCost: Double { __data["totalEuroCost"] }
          public var gemsEarned: Double { __data["gemsEarned"] }
          public var amountLikes: Int { __data["amountLikes"] }
          public var amountViews: Int { __data["amountViews"] }
          public var amountComments: Int { __data["amountComments"] }
          public var amountDislikes: Int { __data["amountDislikes"] }
          public var amountReports: Int { __data["amountReports"] }
          public var post: Post { __data["post"] }
          public var user: User { __data["user"] }

          /// AdvertisementHistory.AffectedRows.Advertisement.Post
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
              .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>?.self),
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

            public var id: GQLOperationsUser.ID { __data["id"] }
            public var contenttype: String { __data["contenttype"] }
            public var title: String { __data["title"] }
            public var media: String { __data["media"] }
            public var cover: String { __data["cover"] }
            public var mediadescription: String { __data["mediadescription"] }
            public var createdat: GQLOperationsUser.Date { __data["createdat"] }
            public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>? { __data["visibilityStatus"] }
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

            /// AdvertisementHistory.AffectedRows.Advertisement.Post.User
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
                .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>?.self),
                .field("hasActiveReports", Bool.self),
              ] }

              public var id: GQLOperationsUser.ID { __data["id"] }
              public var username: String? { __data["username"] }
              public var slug: Int? { __data["slug"] }
              public var img: String? { __data["img"] }
              public var isfollowed: Bool? { __data["isfollowed"] }
              public var isfollowing: Bool? { __data["isfollowing"] }
              public var isfriend: Bool? { __data["isfriend"] }
              public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>? { __data["visibilityStatus"] }
              public var hasActiveReports: Bool { __data["hasActiveReports"] }
            }
          }

          /// AdvertisementHistory.AffectedRows.Advertisement.User
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
              .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>?.self),
              .field("hasActiveReports", Bool.self),
            ] }

            public var id: GQLOperationsUser.ID { __data["id"] }
            public var username: String? { __data["username"] }
            public var slug: Int? { __data["slug"] }
            public var img: String? { __data["img"] }
            public var isfollowed: Bool? { __data["isfollowed"] }
            public var isfollowing: Bool? { __data["isfollowing"] }
            public var isfriend: Bool? { __data["isfriend"] }
            public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>? { __data["visibilityStatus"] }
            public var hasActiveReports: Bool { __data["hasActiveReports"] }
          }
        }
      }
    }
  }
}
