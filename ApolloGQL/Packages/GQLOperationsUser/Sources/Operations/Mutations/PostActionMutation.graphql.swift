// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PostActionMutation: GraphQLMutation {
  public static let operationName: String = "PostAction"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation PostAction($postid: ID!, $action: ActionType!) { resolveActionPost(postid: $postid, action: $action) { __typename status ResponseCode } }"#
    ))

  public var postid: ID
  public var action: GraphQLEnum<ActionType>

  public init(
    postid: ID,
    action: GraphQLEnum<ActionType>
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
      .field("resolveActionPost", ResolveActionPost.self, arguments: [
        "postid": .variable("postid"),
        "action": .variable("action")
      ]),
    ] }

    public var resolveActionPost: ResolveActionPost { __data["resolveActionPost"] }

    /// ResolveActionPost
    ///
    /// Parent Type: `DefaultResponse`
    public struct ResolveActionPost: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
