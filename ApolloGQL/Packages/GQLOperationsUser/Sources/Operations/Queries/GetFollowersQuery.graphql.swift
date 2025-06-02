// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFollowersQuery: GraphQLQuery {
  public static let operationName: String = "GetFollowers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFollowers($userid: ID, $offset: Int, $limit: Int) { listFollowRelations(userid: $userid, offset: $offset, limit: $limit) { __typename status ResponseCode affectedRows { __typename followers { __typename id username slug img isfollowed isfollowing } } } }"#
    ))

  public var userid: GraphQLNullable<ID>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    userid: GraphQLNullable<ID>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.userid = userid
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
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
        "userid": .variable("userid"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
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
        .field("status", String?.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String? { __data["status"] }
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
          .field("followers", [Follower]?.self),
        ] }

        public var followers: [Follower]? { __data["followers"] }

        /// ListFollowRelations.AffectedRows.Follower
        ///
        /// Parent Type: `ProfileUser`
        public struct Follower: GQLOperationsUser.SelectionSet {
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
