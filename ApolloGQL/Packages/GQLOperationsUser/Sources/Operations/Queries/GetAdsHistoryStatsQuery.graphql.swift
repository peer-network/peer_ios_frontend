// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAdsHistoryStatsQuery: GraphQLQuery {
  public static let operationName: String = "GetAdsHistoryStats"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetAdsHistoryStats($userId: ID) { advertisementHistory(filter: { userId: $userId }) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename stats { __typename tokenSpent euroSpent amountAds gemsEarned amountLikes amountViews amountComments amountDislikes amountReports } } } }"#
    ))

  public var userId: GraphQLNullable<ID>

  public init(userId: GraphQLNullable<ID>) {
    self.userId = userId
  }

  public var __variables: Variables? { ["userId": userId] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("advertisementHistory", AdvertisementHistory.self, arguments: ["filter": ["userId": .variable("userId")]]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetAdsHistoryStatsQuery.Data.self
    ] }

    public var advertisementHistory: AdvertisementHistory { __data["advertisementHistory"] }

    /// AdvertisementHistory
    ///
    /// Parent Type: `ListedAdvertisementData`
    public struct AdvertisementHistory: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ListedAdvertisementData }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetAdsHistoryStatsQuery.Data.AdvertisementHistory.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// AdvertisementHistory.Meta
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
          GetAdsHistoryStatsQuery.Data.AdvertisementHistory.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// AdvertisementHistory.AffectedRows
      ///
      /// Parent Type: `AdvertisementHistoryResult`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AdvertisementHistoryResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("stats", Stats?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetAdsHistoryStatsQuery.Data.AdvertisementHistory.AffectedRows.self
        ] }

        public var stats: Stats? { __data["stats"] }

        /// AdvertisementHistory.AffectedRows.Stats
        ///
        /// Parent Type: `TotalAdvertisementHistoryStats`
        public struct Stats: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.TotalAdvertisementHistoryStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("tokenSpent", Double.self),
            .field("euroSpent", Double.self),
            .field("amountAds", Int.self),
            .field("gemsEarned", Double.self),
            .field("amountLikes", Int.self),
            .field("amountViews", Int.self),
            .field("amountComments", Int.self),
            .field("amountDislikes", Int.self),
            .field("amountReports", Int.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetAdsHistoryStatsQuery.Data.AdvertisementHistory.AffectedRows.Stats.self
          ] }

          public var tokenSpent: Double { __data["tokenSpent"] }
          public var euroSpent: Double { __data["euroSpent"] }
          public var amountAds: Int { __data["amountAds"] }
          public var gemsEarned: Double { __data["gemsEarned"] }
          public var amountLikes: Int { __data["amountLikes"] }
          public var amountViews: Int { __data["amountViews"] }
          public var amountComments: Int { __data["amountComments"] }
          public var amountDislikes: Int { __data["amountDislikes"] }
          public var amountReports: Int { __data["amountReports"] }
        }
      }
    }
  }
}
