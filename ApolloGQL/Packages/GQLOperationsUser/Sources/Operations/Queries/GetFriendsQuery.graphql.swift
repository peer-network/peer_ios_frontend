// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetFriendsQuery: GraphQLQuery {
  public static let operationName: String = "GetFriends"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetFriends($offset: Int, $limit: Int) { listFriends(contentFilterBy: MYGRANDMALIKES, offset: $offset, limit: $limit) { __typename status ResponseCode affectedRows { __typename userid img username slug } } }"#
    ))

  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listFriends", ListFriends.self, arguments: [
        "contentFilterBy": "MYGRANDMALIKES",
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var listFriends: ListFriends { __data["listFriends"] }

    /// ListFriends
    ///
    /// Parent Type: `UserFriendsResponse`
    public struct ListFriends: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserFriendsResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// ListFriends.AffectedRow
      ///
      /// Parent Type: `Userinfo`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Userinfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userid", GQLOperationsUser.ID?.self),
          .field("img", String?.self),
          .field("username", String?.self),
          .field("slug", Int?.self),
        ] }

        public var userid: GQLOperationsUser.ID? { __data["userid"] }
        public var img: String? { __data["img"] }
        public var username: String? { __data["username"] }
        public var slug: Int? { __data["slug"] }
      }
    }
  }
}
