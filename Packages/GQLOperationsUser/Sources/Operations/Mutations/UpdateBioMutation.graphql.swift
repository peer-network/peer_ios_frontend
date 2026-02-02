// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateBioMutation: GraphQLMutation {
  public static let operationName: String = "UpdateBio"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateBio($biography: String!) { updateBio(biography: $biography) { __typename status RequestId ResponseCode ResponseMessage } }"#
    ))

  public var biography: String

  public init(biography: String) {
    self.biography = biography
  }

  public var __variables: Variables? { ["biography": biography] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateBio", UpdateBio.self, arguments: ["biography": .variable("biography")]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdateBioMutation.Data.self
    ] }

    public var updateBio: UpdateBio { __data["updateBio"] }

    /// UpdateBio
    ///
    /// Parent Type: `DefaultResponse`
    public struct UpdateBio: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("RequestId", String.self),
        .field("ResponseCode", String.self),
        .field("ResponseMessage", String.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateBioMutation.Data.UpdateBio.self
      ] }

      public var status: String { __data["status"] }
      public var requestId: String { __data["RequestId"] }
      public var responseCode: String { __data["ResponseCode"] }
      public var responseMessage: String { __data["ResponseMessage"] }
    }
  }
}
