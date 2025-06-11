// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ListChatsQuery: GraphQLQuery {
  public static let operationName: String = "ListChats"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ListChats { listChats { __typename status counter ResponseCode affectedRows { __typename id image name createdat updatedat chatmessages { __typename id senderid chatid content createdat } chatparticipants { __typename userid img username slug hasaccess } } } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listChats", ListChats.self),
    ] }

    public var listChats: ListChats { __data["listChats"] }

    /// ListChats
    ///
    /// Parent Type: `ChatResponse`
    public struct ListChats: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ChatResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow]?.self),
      ] }

      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow]? { __data["affectedRows"] }

      /// ListChats.AffectedRow
      ///
      /// Parent Type: `Chat`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Chat }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GQLOperationsUser.ID.self),
          .field("image", String.self),
          .field("name", String.self),
          .field("createdat", GQLOperationsUser.Date?.self),
          .field("updatedat", GQLOperationsUser.Date?.self),
          .field("chatmessages", [Chatmessage].self),
          .field("chatparticipants", [Chatparticipant].self),
        ] }

        public var id: GQLOperationsUser.ID { __data["id"] }
        public var image: String { __data["image"] }
        public var name: String { __data["name"] }
        public var createdat: GQLOperationsUser.Date? { __data["createdat"] }
        public var updatedat: GQLOperationsUser.Date? { __data["updatedat"] }
        public var chatmessages: [Chatmessage] { __data["chatmessages"] }
        public var chatparticipants: [Chatparticipant] { __data["chatparticipants"] }

        /// ListChats.AffectedRow.Chatmessage
        ///
        /// Parent Type: `ChatMessage`
        public struct Chatmessage: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ChatMessage }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GQLOperationsUser.ID.self),
            .field("senderid", GQLOperationsUser.ID.self),
            .field("chatid", GQLOperationsUser.ID.self),
            .field("content", String.self),
            .field("createdat", GQLOperationsUser.Date.self),
          ] }

          public var id: GQLOperationsUser.ID { __data["id"] }
          public var senderid: GQLOperationsUser.ID { __data["senderid"] }
          public var chatid: GQLOperationsUser.ID { __data["chatid"] }
          public var content: String { __data["content"] }
          public var createdat: GQLOperationsUser.Date { __data["createdat"] }
        }

        /// ListChats.AffectedRow.Chatparticipant
        ///
        /// Parent Type: `ChatParticipant`
        public struct Chatparticipant: GQLOperationsUser.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.ChatParticipant }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("userid", GQLOperationsUser.ID.self),
            .field("img", String.self),
            .field("username", String.self),
            .field("slug", Int.self),
            .field("hasaccess", Int.self),
          ] }

          public var userid: GQLOperationsUser.ID { __data["userid"] }
          public var img: String { __data["img"] }
          public var username: String { __data["username"] }
          public var slug: Int { __data["slug"] }
          public var hasaccess: Int { __data["hasaccess"] }
        }
      }
    }
  }
}
