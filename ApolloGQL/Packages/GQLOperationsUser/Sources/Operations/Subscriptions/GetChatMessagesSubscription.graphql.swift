// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetChatMessagesSubscription: GraphQLSubscription {
  public static let operationName: String = "GetChatMessages"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"subscription GetChatMessages($chatid: ID!) { getChatMessages(chatid: $chatid) { __typename status counter ResponseCode } }"#
    ))

  public var chatid: ID

  public init(chatid: ID) {
    self.chatid = chatid
  }

  public var __variables: Variables? { ["chatid": chatid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Subscription }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getChatMessages", GetChatMessages.self, arguments: ["chatid": .variable("chatid")]),
    ] }

    public var getChatMessages: GetChatMessages { __data["getChatMessages"] }

    /// GetChatMessages
    ///
    /// Parent Type: `AddChatmessageResponse`
    public struct GetChatMessages: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AddChatmessageResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
