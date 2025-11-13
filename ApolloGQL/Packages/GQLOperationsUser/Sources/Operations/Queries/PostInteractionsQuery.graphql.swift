// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PostInteractionsQuery: GraphQLQuery {
  public static let operationName: String = "PostInteractions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query PostInteractions($getOnly: GetOnly!, $postOrCommentId: ID!, $offset: Int, $limit: Int) { postInteractions( getOnly: $getOnly postOrCommentId: $postOrCommentId offset: $offset limit: $limit ) { __typename status ResponseCode affectedRows { __typename id username slug img visibilityStatus hasActiveReports isfollowed isfollowing isfriend } } }"#
    ))

  public var getOnly: GraphQLEnum<GetOnly>
  public var postOrCommentId: ID
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    getOnly: GraphQLEnum<GetOnly>,
    postOrCommentId: ID,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.getOnly = getOnly
    self.postOrCommentId = postOrCommentId
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "getOnly": getOnly,
    "postOrCommentId": postOrCommentId,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("postInteractions", PostInteractions?.self, arguments: [
        "getOnly": .variable("getOnly"),
        "postOrCommentId": .variable("postOrCommentId"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var postInteractions: PostInteractions? { __data["postInteractions"] }

    /// PostInteractions
    ///
    /// Parent Type: `PostInteractionResponse`
    public struct PostInteractions: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.PostInteractionResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// PostInteractions.AffectedRow
      ///
      /// Parent Type: `ProfileUser`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ProfileUser }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GQLOperationsUser.ID.self),
          .field("username", String?.self),
          .field("slug", Int?.self),
          .field("img", String?.self),
          .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>?.self),
          .field("hasActiveReports", Bool.self),
          .field("isfollowed", Bool?.self),
          .field("isfollowing", Bool?.self),
          .field("isfriend", Bool?.self),
        ] }

        public var id: GQLOperationsUser.ID { __data["id"] }
        public var username: String? { __data["username"] }
        public var slug: Int? { __data["slug"] }
        public var img: String? { __data["img"] }
        public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>? { __data["visibilityStatus"] }
        public var hasActiveReports: Bool { __data["hasActiveReports"] }
        public var isfollowed: Bool? { __data["isfollowed"] }
        public var isfollowing: Bool? { __data["isfollowing"] }
        public var isfriend: Bool? { __data["isfriend"] }
      }
    }
  }
}
