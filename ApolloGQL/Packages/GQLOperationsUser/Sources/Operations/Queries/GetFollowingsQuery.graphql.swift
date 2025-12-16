// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFollowingsQuery: GraphQLQuery {
  public static let operationName: String = "GetFollowings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFollowings($contentFilterBy: ContentFilterType, $userid: ID, $offset: Int, $limit: Int) { listFollowRelations( contentFilterBy: $contentFilterBy userid: $userid offset: $offset limit: $limit ) { __typename status ResponseCode affectedRows { __typename following { __typename id username slug img isfollowed isfollowing } } } }"#
    ))

  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var userid: GraphQLNullable<ID>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    userid: GraphQLNullable<ID>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.contentFilterBy = contentFilterBy
    self.userid = userid
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "contentFilterBy": contentFilterBy,
    "userid": userid,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listFollowRelations", ListFollowRelations.self, arguments: [
        "contentFilterBy": .variable("contentFilterBy"),
        "userid": .variable("userid"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetFollowingsQuery.Data.self
    ] }

    public var listFollowRelations: ListFollowRelations { __data["listFollowRelations"] }

    /// ListFollowRelations
    ///
    /// Parent Type: `FollowRelationsResponse`
    public struct ListFollowRelations: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.FollowRelationsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetFollowingsQuery.Data.ListFollowRelations.self
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// ListFollowRelations.AffectedRows
      ///
      /// Parent Type: `FollowRelations`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.FollowRelations }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("following", [Following]?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetFollowingsQuery.Data.ListFollowRelations.AffectedRows.self
        ] }

        public var following: [Following]? { __data["following"] }

        /// ListFollowRelations.AffectedRows.Following
        ///
        /// Parent Type: `ProfileUser`
        public struct Following: GQLOperationsUser.SelectionSet {
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
            GetFollowingsQuery.Data.ListFollowRelations.AffectedRows.Following.self
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var img: String? { __data["img"] }
          @available(*, deprecated, message: "Use iFollowThisUser / thisUserFollowsMe")
          public var isfollowed: Bool? { __data["isfollowed"] }
          @available(*, deprecated, message: "Use iFollowThisUser / thisUserFollowsMe")
          public var isfollowing: Bool? { __data["isfollowing"] }
        }
      }
    }
  }
}
