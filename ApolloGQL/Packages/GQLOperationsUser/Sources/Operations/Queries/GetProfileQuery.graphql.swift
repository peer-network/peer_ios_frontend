// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetProfileQuery: GraphQLQuery {
  public static let operationName: String = "GetProfile"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetProfile($contentFilterBy: ContentFilterType, $userid: ID!) { getProfile(contentFilterBy: $contentFilterBy, userid: $userid) { __typename status ResponseCode affectedRows { __typename id username status slug img biography visibilityStatus isHiddenForUsers hasActiveReports isfollowed isfollowing amountposts amounttrending amountfollowed amountfollower amountfriends amountblocked amountreports } } }"#
    ))

  public var contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>
  public var userid: ID

  public init(
    contentFilterBy: GraphQLNullable<GraphQLEnum<ContentFilterType>>,
    userid: ID
  ) {
    self.contentFilterBy = contentFilterBy
    self.userid = userid
  }

  public var __variables: Variables? { [
    "contentFilterBy": contentFilterBy,
    "userid": userid
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getProfile", GetProfile.self, arguments: [
        "contentFilterBy": .variable("contentFilterBy"),
        "userid": .variable("userid")
      ]),
    ] }

    public var getProfile: GetProfile { __data["getProfile"] }

    /// GetProfile
    ///
    /// Parent Type: `ProfileInfo`
    public struct GetProfile: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ProfileInfo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String?.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String? { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// GetProfile.AffectedRows
      ///
      /// Parent Type: `Profile`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Profile }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GQLOperationsUser.ID?.self),
          .field("username", String?.self),
          .field("status", Int?.self),
          .field("slug", Int?.self),
          .field("img", String?.self),
          .field("biography", String?.self),
          .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
          .field("isHiddenForUsers", Bool.self),
          .field("hasActiveReports", Bool.self),
          .field("isfollowed", Bool?.self),
          .field("isfollowing", Bool?.self),
          .field("amountposts", Int?.self),
          .field("amounttrending", Int?.self),
          .field("amountfollowed", Int?.self),
          .field("amountfollower", Int?.self),
          .field("amountfriends", Int?.self),
          .field("amountblocked", Int?.self),
          .field("amountreports", Int?.self),
        ] }

        public var id: GQLOperationsUser.ID? { __data["id"] }
        public var username: String? { __data["username"] }
        public var status: Int? { __data["status"] }
        public var slug: Int? { __data["slug"] }
        public var img: String? { __data["img"] }
        public var biography: String? { __data["biography"] }
        public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
        public var isHiddenForUsers: Bool { __data["isHiddenForUsers"] }
        public var hasActiveReports: Bool { __data["hasActiveReports"] }
        public var isfollowed: Bool? { __data["isfollowed"] }
        public var isfollowing: Bool? { __data["isfollowing"] }
        public var amountposts: Int? { __data["amountposts"] }
        public var amounttrending: Int? { __data["amounttrending"] }
        public var amountfollowed: Int? { __data["amountfollowed"] }
        public var amountfollower: Int? { __data["amountfollower"] }
        public var amountfriends: Int? { __data["amountfriends"] }
        public var amountblocked: Int? { __data["amountblocked"] }
        public var amountreports: Int? { __data["amountreports"] }
      }
    }
  }
}
