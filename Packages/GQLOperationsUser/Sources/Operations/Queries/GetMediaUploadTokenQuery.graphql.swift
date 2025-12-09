// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMediaUploadTokenQuery: GraphQLQuery {
  public static let operationName: String = "GetMediaUploadToken"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMediaUploadToken { postEligibility { __typename status ResponseCode eligibilityToken } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("postEligibility", PostEligibility.self),
    ] }

    public var postEligibility: PostEligibility { __data["postEligibility"] }

    /// PostEligibility
    ///
    /// Parent Type: `PostEligibilityResponse`
    public struct PostEligibility: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.PostEligibilityResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("eligibilityToken", String.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var eligibilityToken: String { __data["eligibilityToken"] }
    }
  }
}
