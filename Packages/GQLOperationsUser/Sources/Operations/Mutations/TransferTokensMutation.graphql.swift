// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TransferTokensMutation: GraphQLMutation {
  public static let operationName: String = "TransferTokens"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation TransferTokens($recipient: ID!, $numberoftokens: Decimal!, $message: String) { resolveTransferV2( recipient: $recipient numberoftokens: $numberoftokens message: $message ) { __typename status ResponseCode } }"#
    ))

  public var recipient: ID
  public var numberoftokens: Decimal
  public var message: GraphQLNullable<String>

  public init(
    recipient: ID,
    numberoftokens: Decimal,
    message: GraphQLNullable<String>
  ) {
    self.recipient = recipient
    self.numberoftokens = numberoftokens
    self.message = message
  }

  public var __variables: Variables? { [
    "recipient": recipient,
    "numberoftokens": numberoftokens,
    "message": message
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("resolveTransferV2", ResolveTransferV2.self, arguments: [
        "recipient": .variable("recipient"),
        "numberoftokens": .variable("numberoftokens"),
        "message": .variable("message")
      ]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TransferTokensMutation.Data.self
    ] }

    public var resolveTransferV2: ResolveTransferV2 { __data["resolveTransferV2"] }

    /// ResolveTransferV2
    ///
    /// Parent Type: `TransferTokenResponse`
    public struct ResolveTransferV2: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.TransferTokenResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TransferTokensMutation.Data.ResolveTransferV2.self
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
