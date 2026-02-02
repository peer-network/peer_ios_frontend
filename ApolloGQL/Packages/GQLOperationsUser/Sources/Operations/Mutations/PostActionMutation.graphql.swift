// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PostActionMutation: GraphQLMutation {
  public static let operationName: String = "PostAction"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation PostAction($postid: ID!, $action: PostActionType!) { resolvePostAction(postid: $postid, action: $action) { __typename status RequestId ResponseCode ResponseMessage } }"#
    ))

  public var postid: ID
  public var action: GraphQLEnum<PostActionType>

  public init(
    postid: ID,
    action: GraphQLEnum<PostActionType>
  ) {
    self.postid = postid
    self.action = action
  }

  public var __variables: Variables? { [
    "postid": postid,
    "action": action
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("resolvePostAction", ResolvePostAction.self, arguments: [
        "postid": .variable("postid"),
        "action": .variable("action")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PostActionMutation.Data.self
    ] }

    public var resolvePostAction: ResolvePostAction { __data["resolvePostAction"] }

    /// ResolvePostAction
    ///
    /// Parent Type: `DefaultResponse`
    public struct ResolvePostAction: GQLOperationsUser.SelectionSet {
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
        PostActionMutation.Data.ResolvePostAction.self
      ] }

      public var status: String { __data["status"] }
      public var requestId: String { __data["RequestId"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var responseMessage: String { __data["ResponseMessage"] }
    }
  }
}
