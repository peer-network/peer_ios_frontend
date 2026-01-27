// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FollowUserMutation: GraphQLMutation {
  public static let operationName: String = "FollowUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation FollowUser($userid: ID!) { toggleUserFollowStatus(userid: $userid) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } isfollowing } }"#
    ))

  public var userid: ID

  public init(userid: ID) {
    self.userid = userid
  }

  public var __variables: Variables? { ["userid": userid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("toggleUserFollowStatus", ToggleUserFollowStatus.self, arguments: ["userid": .variable("userid")]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      FollowUserMutation.Data.self
    ] }

    public var toggleUserFollowStatus: ToggleUserFollowStatus { __data["toggleUserFollowStatus"] }

    /// ToggleUserFollowStatus
    ///
    /// Parent Type: `FollowStatusResponse`
    public struct ToggleUserFollowStatus: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.FollowStatusResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("isfollowing", Bool?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        FollowUserMutation.Data.ToggleUserFollowStatus.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var isfollowing: Bool? { __data["isfollowing"] }

      /// ToggleUserFollowStatus.Meta
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
          FollowUserMutation.Data.ToggleUserFollowStatus.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }
    }
  }
}
