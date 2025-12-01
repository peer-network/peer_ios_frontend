// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTransactionHistoryQuery: GraphQLQuery {
  public static let operationName: String = "GetTransactionHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetTransactionHistory($offset: Int, $limit: Int) { transactionHistory(limit: $limit, offset: $offset, sort: NEWEST) { __typename affectedRows { __typename operationid transactiontype tokenamount netTokenAmount message createdat fees { __typename total burn peer inviter } recipient { __typename userid img username slug biography visibilityStatus hasActiveReports updatedat } sender { __typename userid img username slug biography visibilityStatus hasActiveReports updatedat } } meta { __typename status RequestId ResponseCode ResponseMessage } } }"#
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
      .field("transactionHistory", TransactionHistory.self, arguments: [
        "limit": .variable("limit"),
        "offset": .variable("offset"),
        "sort": "NEWEST"
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetTransactionHistoryQuery.Data.self
    ] }

    public var transactionHistory: TransactionHistory { __data["transactionHistory"] }

    /// TransactionHistory
    ///
    /// Parent Type: `TransactionHistotyResponse`
    public struct TransactionHistory: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.TransactionHistotyResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("affectedRows", [AffectedRow]?.self),
        .field("meta", Meta?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetTransactionHistoryQuery.Data.TransactionHistory.self
      ] }

      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }
      public var meta: Meta? { __data["meta"] }

      /// TransactionHistory.AffectedRow
      ///
      /// Parent Type: `TransactionHistotyItem`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.TransactionHistotyItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("operationid", String.self),
          .field("transactiontype", String.self),
          .field("tokenamount", GQLOperationsUser.Decimal.self),
          .field("netTokenAmount", GQLOperationsUser.Decimal.self),
          .field("message", String.self),
          .field("createdat", String.self),
          .field("fees", Fees?.self),
          .field("recipient", Recipient.self),
          .field("sender", Sender.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.self
        ] }

        public var operationid: String { __data["operationid"] }
        public var transactiontype: String { __data["transactiontype"] }
        public var tokenamount: GQLOperationsUser.Decimal { __data["tokenamount"] }
        public var netTokenAmount: GQLOperationsUser.Decimal { __data["netTokenAmount"] }
        public var message: String { __data["message"] }
        public var createdat: String { __data["createdat"] }
        public var fees: Fees? { __data["fees"] }
        public var recipient: Recipient { __data["recipient"] }
        public var sender: Sender { __data["sender"] }

        /// TransactionHistory.AffectedRow.Fees
        ///
        /// Parent Type: `TransactionFeeSummary`
        public struct Fees: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.TransactionFeeSummary }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("total", GQLOperationsUser.Decimal?.self),
            .field("burn", GQLOperationsUser.Decimal?.self),
            .field("peer", GQLOperationsUser.Decimal?.self),
            .field("inviter", GQLOperationsUser.Decimal?.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Fees.self
          ] }

          public var total: GQLOperationsUser.Decimal? { __data["total"] }
          public var burn: GQLOperationsUser.Decimal? { __data["burn"] }
          public var peer: GQLOperationsUser.Decimal? { __data["peer"] }
          public var inviter: GQLOperationsUser.Decimal? { __data["inviter"] }
        }

        /// TransactionHistory.AffectedRow.Recipient
        ///
        /// Parent Type: `BasicUserInfo`
        public struct Recipient: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.BasicUserInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("userid", GQLOperationsUser.ID?.self),
            .field("img", String?.self),
            .field("username", String?.self),
            .field("slug", Int?.self),
            .field("biography", String?.self),
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("hasActiveReports", Bool.self),
            .field("updatedat", GQLOperationsUser.Date.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Recipient.self
          ] }

          public var userid: GQLOperationsUser.ID? { __data["userid"] }
          public var img: String? { __data["img"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var biography: String? { __data["biography"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
          public var updatedat: GQLOperationsUser.Date { __data["updatedat"] }
        }

        /// TransactionHistory.AffectedRow.Sender
        ///
        /// Parent Type: `BasicUserInfo`
        public struct Sender: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.BasicUserInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("userid", GQLOperationsUser.ID?.self),
            .field("img", String?.self),
            .field("username", String?.self),
            .field("slug", Int?.self),
            .field("biography", String?.self),
            .field("visibilityStatus", GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus>.self),
            .field("hasActiveReports", Bool.self),
            .field("updatedat", GQLOperationsUser.Date.self),
          ] }
          public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetTransactionHistoryQuery.Data.TransactionHistory.AffectedRow.Sender.self
          ] }

          public var userid: GQLOperationsUser.ID? { __data["userid"] }
          public var img: String? { __data["img"] }
          public var username: String? { __data["username"] }
          public var slug: Int? { __data["slug"] }
          public var biography: String? { __data["biography"] }
          public var visibilityStatus: GraphQLEnum<GQLOperationsUser.ContentVisibilityStatus> { __data["visibilityStatus"] }
          public var hasActiveReports: Bool { __data["hasActiveReports"] }
          public var updatedat: GQLOperationsUser.Date { __data["updatedat"] }
        }
      }

      /// TransactionHistory.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String?.self),
          .field("ResponseCode", String?.self),
          .field("ResponseMessage", String?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetTransactionHistoryQuery.Data.TransactionHistory.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }
    }
  }
}
