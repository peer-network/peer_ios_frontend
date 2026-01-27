// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LikeCommentMutation: GraphQLMutation {
  public static let operationName: String = "LikeComment"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation LikeComment($commentid: ID!) { likeComment(commentid: $commentid) { __typename status RequestId ResponseCode ResponseMessage } }"#
    ))

  public var commentid: ID

  public init(commentid: ID) {
    self.commentid = commentid
  }

  public var __variables: Variables? { ["commentid": commentid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("likeComment", LikeComment.self, arguments: ["commentid": .variable("commentid")]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      LikeCommentMutation.Data.self
    ] }

    public var likeComment: LikeComment { __data["likeComment"] }

    /// LikeComment
    ///
    /// Parent Type: `DefaultResponse`
    public struct LikeComment: GQLOperationsUser.SelectionSet {
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
        LikeCommentMutation.Data.LikeComment.self
      ] }

      public var status: String { __data["status"] }
      public var requestId: String? { __data["RequestId"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var responseMessage: String? { __data["ResponseMessage"] }
    }
  }
}
