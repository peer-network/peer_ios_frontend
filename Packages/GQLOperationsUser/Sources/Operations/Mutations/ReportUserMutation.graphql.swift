// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ReportUserMutation: GraphQLMutation {
  public static let operationName: String = "ReportUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation ReportUser($userid: ID!) { reportUser(userid: $userid) { __typename status ResponseCode } }"#
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
      .field("reportUser", ReportUser.self, arguments: ["userid": .variable("userid")]),
    ] }

    public var reportUser: ReportUser { __data["reportUser"] }

    /// ReportUser
    ///
    /// Parent Type: `DefaultResponse`
    public struct ReportUser: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String { __data["ResponseCode"] }
    }
  }
}
