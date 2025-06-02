// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchUserQuery: GraphQLQuery {
  public static let operationName: String = "SearchUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchUser($userid: ID, $username: String, $offset: Int, $limit: Int) { searchUser(userid: $userid, username: $username, offset: $offset, limit: $limit) { __typename status counter ResponseCode affectedRows { __typename id username status slug img biography } } }"#
    ))

  public var userid: GraphQLNullable<ID>
  public var username: GraphQLNullable<String>
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    userid: GraphQLNullable<ID>,
    username: GraphQLNullable<String>,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.userid = userid
    self.username = username
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "userid": userid,
    "username": username,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchUser", SearchUser.self, arguments: [
        "userid": .variable("userid"),
        "username": .variable("username"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var searchUser: SearchUser { __data["searchUser"] }

    /// SearchUser
    ///
    /// Parent Type: `UserListResponse`
    public struct SearchUser: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserListResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// SearchUser.AffectedRow
      ///
      /// Parent Type: `User`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GQLOperationsUser.ID?.self),
          .field("username", String?.self),
          .field("status", Int?.self),
          .field("slug", Int?.self),
          .field("img", String?.self),
          .field("biography", String?.self),
        ] }

        public var id: GQLOperationsUser.ID? { __data["id"] }
        public var username: String? { __data["username"] }
        public var status: Int? { __data["status"] }
        public var slug: Int? { __data["slug"] }
        public var img: String? { __data["img"] }
        public var biography: String? { __data["biography"] }
      }
    }
  }
}
