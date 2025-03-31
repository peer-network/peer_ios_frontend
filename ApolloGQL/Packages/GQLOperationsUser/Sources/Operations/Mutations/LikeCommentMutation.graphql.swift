// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LikeCommentMutation: GraphQLMutation {
  public static let operationName: String = "LikeComment"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation LikeComment($commentid: ID!) { likeComment(commentid: $commentid) { __typename status ResponseCode } }"#
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
        .field("ResponseCode", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
