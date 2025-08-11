// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetUserInfoQuery: GraphQLQuery {
  public static let operationName: String = "GetUserInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetUserInfo { getUserInfo { __typename status ResponseCode affectedRows { __typename userid liquidity amountposts amountblocked amountfollower amountfollowed amountfriends invited updatedat userPreferences { __typename contentFilteringSeverityLevel } } } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getUserInfo", GetUserInfo.self),
    ] }

    public var getUserInfo: GetUserInfo { __data["getUserInfo"] }

    /// GetUserInfo
    ///
    /// Parent Type: `UserInfoResponse`
    public struct GetUserInfo: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserInfoResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// GetUserInfo.AffectedRows
      ///
      /// Parent Type: `UserInfo`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userid", GQLOperationsUser.ID.self),
          .field("liquidity", GQLOperationsUser.Decimal.self),
          .field("amountposts", Int.self),
          .field("amountblocked", Int.self),
          .field("amountfollower", Int.self),
          .field("amountfollowed", Int.self),
          .field("amountfriends", Int.self),
          .field("invited", GQLOperationsUser.ID.self),
          .field("updatedat", GQLOperationsUser.Date?.self),
          .field("userPreferences", UserPreferences?.self),
        ] }

        public var userid: GQLOperationsUser.ID { __data["userid"] }
        public var liquidity: GQLOperationsUser.Decimal { __data["liquidity"] }
        public var amountposts: Int { __data["amountposts"] }
        public var amountblocked: Int { __data["amountblocked"] }
        public var amountfollower: Int { __data["amountfollower"] }
        public var amountfollowed: Int { __data["amountfollowed"] }
        public var amountfriends: Int { __data["amountfriends"] }
        public var invited: GQLOperationsUser.ID { __data["invited"] }
        public var updatedat: GQLOperationsUser.Date? { __data["updatedat"] }
        public var userPreferences: UserPreferences? { __data["userPreferences"] }

        /// GetUserInfo.AffectedRows.UserPreferences
        ///
        /// Parent Type: `UserPreferences`
        public struct UserPreferences: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserPreferences }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("contentFilteringSeverityLevel", GraphQLEnum<GQLOperationsUser.ContentFilterType>?.self),
          ] }

          public var contentFilteringSeverityLevel: GraphQLEnum<GQLOperationsUser.ContentFilterType>? { __data["contentFilteringSeverityLevel"] }
        }
      }
    }
  }
}
