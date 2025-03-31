// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RefreshTokenMutation: GraphQLMutation {
  public static let operationName: String = "RefreshToken"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation RefreshToken($refreshToken: String!) { refreshToken(refreshToken: $refreshToken) { __typename status ResponseCode accessToken refreshToken } }"#
    ))

  public var refreshToken: String

  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }

  public var __variables: Variables? { ["refreshToken": refreshToken] }

  public struct Data: GQLOperationsGuest.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("refreshToken", RefreshToken.self, arguments: ["refreshToken": .variable("refreshToken")]),
    ] }

    public var refreshToken: RefreshToken { __data["refreshToken"] }

    /// RefreshToken
    ///
    /// Parent Type: `AuthPayload`
    public struct RefreshToken: GQLOperationsGuest.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsGuest.Objects.AuthPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("accessToken", String?.self),
        .field("refreshToken", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var accessToken: String? { __data["accessToken"] }
      public var refreshToken: String? { __data["refreshToken"] }
    }
  }
}
