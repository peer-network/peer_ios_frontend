// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateChatMutation: GraphQLMutation {
  public static let operationName: String = "CreateChat"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateChat($name: String!, $recipients: [String!]!, $image: String) { createChat(input: { name: $name, recipients: $recipients, image: $image }) { __typename status ResponseCode affectedRows { __typename chatid } } }"#
    ))

  public var name: String
  public var recipients: [String]
  public var image: GraphQLNullable<String>

  public init(
    name: String,
    recipients: [String],
    image: GraphQLNullable<String>
  ) {
    self.name = name
    self.recipients = recipients
    self.image = image
  }

  public var __variables: Variables? { [
    "name": name,
    "recipients": recipients,
    "image": image
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createChat", CreateChat.self, arguments: ["input": [
        "name": .variable("name"),
        "recipients": .variable("recipients"),
        "image": .variable("image")
      ]]),
    ] }

    public var createChat: CreateChat { __data["createChat"] }

    /// CreateChat
    ///
    /// Parent Type: `AddChatResponse`
    public struct CreateChat: GQLOperationsUser.SelectionSet {
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

      /// CreateChat.AffectedRows
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
