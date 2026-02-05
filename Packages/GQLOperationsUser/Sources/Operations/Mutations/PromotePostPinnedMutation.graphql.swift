// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PromotePostPinnedMutation: GraphQLMutation {
  public static let operationName: String = "PromotePostPinned"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation PromotePostPinned($postid: ID!) { advertisePostPinned(postid: $postid, advertisePlan: PINNED) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename timeframeEnd } } }"#
    ))

  public var postid: ID

  public init(postid: ID) {
    self.postid = postid
  }

  public var __variables: Variables? { ["postid": postid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("advertisePostPinned", AdvertisePostPinned.self, arguments: [
        "postid": .variable("postid"),
        "advertisePlan": "PINNED"
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PromotePostPinnedMutation.Data.self
    ] }

    public var advertisePostPinned: AdvertisePostPinned { __data["advertisePostPinned"] }

    /// AdvertisePostPinned
    ///
    /// Parent Type: `ListAdvertisementData`
    public struct AdvertisePostPinned: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ListAdvertisementData }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PromotePostPinnedMutation.Data.AdvertisePostPinned.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// AdvertisePostPinned.Meta
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
          PromotePostPinnedMutation.Data.AdvertisePostPinned.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// AdvertisePostPinned.AffectedRow
      ///
      /// Parent Type: `AdvertisementRow`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AdvertisementRow }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("timeframeEnd", GQLOperationsUser.Date.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PromotePostPinnedMutation.Data.AdvertisePostPinned.AffectedRow.self
        ] }

        public var timeframeEnd: GQLOperationsUser.Date { __data["timeframeEnd"] }
      }
    }
  }
}
