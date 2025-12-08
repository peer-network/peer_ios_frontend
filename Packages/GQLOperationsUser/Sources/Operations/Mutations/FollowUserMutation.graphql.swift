// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FollowUserMutation: GraphQLMutation {
  public static let operationName: String = "FollowUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation FollowUser($userid: ID!) { toggleUserFollowStatus(userid: $userid) { __typename status ResponseCode isfollowing } }"#
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("isfollowing", Bool?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var isfollowing: Bool? { __data["isfollowing"] }
    }
  }
}
