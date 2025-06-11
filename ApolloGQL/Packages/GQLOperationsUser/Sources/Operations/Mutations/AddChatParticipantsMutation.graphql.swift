// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddChatParticipantsMutation: GraphQLMutation {
  public static let operationName: String = "AddChatParticipants"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation AddChatParticipants($chatid: ID!, $recipients: [String!]!) { addChatParticipants(input: { chatid: $chatid, recipients: $recipients }) { __typename status ResponseCode affectedRows { __typename chatid } } }"#
    ))

  public var chatid: ID
  public var recipients: [String]

  public init(
    chatid: ID,
    recipients: [String]
  ) {
    self.chatid = chatid
    self.recipients = recipients
  }

  public var __variables: Variables? { [
    "chatid": chatid,
    "recipients": recipients
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addChatParticipants", AddChatParticipants.self, arguments: ["input": [
        "chatid": .variable("chatid"),
        "recipients": .variable("recipients")
      ]]),
    ] }

    public var addChatParticipants: AddChatParticipants { __data["addChatParticipants"] }

    /// AddChatParticipants
    ///
    /// Parent Type: `AddChatResponse`
    public struct AddChatParticipants: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.AddChatResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// AddChatParticipants.AffectedRows
      ///
      /// Parent Type: `Chatinfo`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Chatinfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("chatid", GQLOperationsUser.ID?.self),
        ] }

        public var chatid: GQLOperationsUser.ID? { __data["chatid"] }
      }
    }
  }
}
