// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetProfileQuery: GraphQLQuery {
  public static let operationName: String = "GetProfile"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetProfile($userid: ID!) { getProfile(contentFilterBy: MYGRANDMALIKES, userid: $userid) { __typename status ResponseCode affectedRows { __typename id username status slug img biography isfollowed isfollowing amountposts amounttrending amountfollowed amountfollower amountfriends amountblocked } } }"#
    ))

  public var userid: ID

  public init(userid: ID) {
    self.userid = userid
  }

  public var __variables: Variables? { ["userid": userid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getProfile", GetProfile.self, arguments: [
        "contentFilterBy": "MYGRANDMALIKES",
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
          .field("isfollowed", Bool?.self),
          .field("isfollowing", Bool?.self),
          .field("amountposts", Int?.self),
          .field("amounttrending", Int?.self),
          .field("amountfollowed", Int?.self),
          .field("amountfollower", Int?.self),
          .field("amountfriends", Int?.self),
          .field("amountblocked", Int?.self),
        ] }

        public var id: GQLOperationsUser.ID? { __data["id"] }
        public var username: String? { __data["username"] }
        public var status: Int? { __data["status"] }
        public var slug: Int? { __data["slug"] }
        public var img: String? { __data["img"] }
        public var biography: String? { __data["biography"] }
        public var isfollowed: Bool? { __data["isfollowed"] }
        public var isfollowing: Bool? { __data["isfollowing"] }
        public var amountposts: Int? { __data["amountposts"] }
        public var amounttrending: Int? { __data["amounttrending"] }
        public var amountfollowed: Int? { __data["amountfollowed"] }
        public var amountfollower: Int? { __data["amountfollower"] }
        public var amountfriends: Int? { __data["amountfriends"] }
        public var amountblocked: Int? { __data["amountblocked"] }
      }
    }
  }
}
