// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ListChatMessagesQuery: GraphQLQuery {
  public static let operationName: String = "ListChatMessages"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ListChatMessages($chatid: ID!) { listChatMessages(chatid: $chatid) { __typename status counter ResponseCode affectedRows { __typename messid chatid userid content createdat } } }"#
    ))

  public var chatid: ID

  public init(chatid: ID) {
    self.chatid = chatid
  }

  public var __variables: Variables? { ["chatid": chatid] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listChatMessages", ListChatMessages.self, arguments: ["chatid": .variable("chatid")]),
    ] }

    public var listChatMessages: ListChatMessages { __data["listChatMessages"] }

    /// ListChatMessages
    ///
    /// Parent Type: `AddChatmessageResponse`
    public struct ListChatMessages: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AddChatmessageResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// ListChatMessages.AffectedRow
      ///
      /// Parent Type: `ChatMessageInfo`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ChatMessageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("messid", GQLOperationsUser.ID?.self),
          .field("chatid", GQLOperationsUser.ID?.self),
          .field("userid", GQLOperationsUser.ID?.self),
          .field("content", String?.self),
          .field("createdat", GQLOperationsUser.Date?.self),
        ] }

        public var messid: GQLOperationsUser.ID? { __data["messid"] }
        public var chatid: GQLOperationsUser.ID? { __data["chatid"] }
        public var userid: GQLOperationsUser.ID? { __data["userid"] }
        public var content: String? { __data["content"] }
        public var createdat: GQLOperationsUser.Date? { __data["createdat"] }
      }
    }
  }
}
