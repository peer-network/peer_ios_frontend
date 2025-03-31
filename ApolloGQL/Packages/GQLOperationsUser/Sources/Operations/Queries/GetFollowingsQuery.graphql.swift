// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFollowingsQuery: GraphQLQuery {
  public static let operationName: String = "GetFollowings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFollowings($userid: ID, $offset: Int, $limit: Int) { follows(userid: $userid, offset: $offset, limit: $limit) { __typename status ResponseCode affectedRows { __typename following { __typename id username slug img isfollowed isfollowing } } } }"#
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
      .field("follows", Follows.self, arguments: [
        "userid": .variable("userid"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var follows: Follows { __data["follows"] }

    /// Follows
    ///
    /// Parent Type: `UserFollows`
    public struct Follows: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserFollows }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String?.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String? { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// Follows.AffectedRows
      ///
      /// Parent Type: `Followes`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Followes }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("following", [Following]?.self),
        ] }

        public var following: [Following]? { __data["following"] }

        /// Follows.AffectedRows.Following
        ///
        /// Parent Type: `ProfilUser`
        public struct Following: GQLOperationsUser.SelectionSet {
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
