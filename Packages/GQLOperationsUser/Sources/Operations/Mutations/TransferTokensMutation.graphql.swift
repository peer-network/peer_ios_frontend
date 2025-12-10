// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TransferTokensMutation: GraphQLMutation {
  public static let operationName: String = "TransferTokens"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation TransferTokens($recipient: ID!, $numberoftokens: Int!) { resolveTransfer(recipient: $recipient, numberoftokens: $numberoftokens) { __typename status ResponseCode } }"#
    ))

  public var recipient: ID
  public var numberoftokens: Int

  public init(
    recipient: ID,
    numberoftokens: Int
  ) {
    self.recipient = recipient
    self.numberoftokens = numberoftokens
  }

  public var __variables: Variables? { [
    "recipient": recipient,
    "numberoftokens": numberoftokens
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("resolveTransfer", ResolveTransfer.self, arguments: [
        "recipient": .variable("recipient"),
        "numberoftokens": .variable("numberoftokens")
      ]),
    ] }

    @available(*, deprecated, message: "Use `resolveTransferV2`.")
    public var resolveTransfer: ResolveTransfer { __data["resolveTransfer"] }

    /// ResolveTransfer
    ///
    /// Parent Type: `DefaultResponse`
    public struct ResolveTransfer: GQLOperationsUser.SelectionSet {
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
