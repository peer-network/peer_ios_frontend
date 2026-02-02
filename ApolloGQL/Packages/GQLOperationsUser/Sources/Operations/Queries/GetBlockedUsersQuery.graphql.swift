// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetBlockedUsersQuery: GraphQLQuery {
  public static let operationName: String = "GetBlockedUsers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetBlockedUsers($offset: Int, $limit: Int) { listBlockedUsers(offset: $offset, limit: $limit) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename iBlocked { __typename userid img username slug visibilityStatus hasActiveReports isHiddenForUsers } } } }"#
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
      .field("listBlockedUsers", ListBlockedUsers.self, arguments: [
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetBlockedUsersQuery.Data.self
    ] }

    public var listBlockedUsers: ListBlockedUsers { __data["listBlockedUsers"] }

    /// ListBlockedUsers
    ///
    /// Parent Type: `BlockedUsersResponse`
    public struct ListBlockedUsers: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.BlockedUsersResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetBlockedUsersQuery.Data.ListBlockedUsers.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// ListBlockedUsers.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String.self),
          .field("ResponseCode", String.self),
          .field("ResponseMessage", String.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetBlockedUsersQuery.Data.ListBlockedUsers.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// ListBlockedUsers.AffectedRows
      ///
      /// Parent Type: `BlockedUsers`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.BlockedUsers }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("iBlocked", [IBlocked]?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetBlockedUsersQuery.Data.ListBlockedUsers.AffectedRows.self
        ] }

        public var iBlocked: [IBlocked]? { __data["iBlocked"] }

        /// ListBlockedUsers.AffectedRows.IBlocked
        ///
        /// Parent Type: `BlockedUser`
        public struct IBlocked: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.BlockedUser }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("userid", String?.self),
            .field("img", String?.self),
            .field("username", String?.self),
            .field("slug", Int?.self),
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("hasActiveReports", Bool.self),
            .field("isHiddenForUsers", Bool.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetBlockedUsersQuery.Data.ListBlockedUsers.AffectedRows.IBlocked.self
          ] }

          public var userid: String? { __data["userid"] }
          public var img: String? { __data["img"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
          public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
        }
      }
    }
  }
}
