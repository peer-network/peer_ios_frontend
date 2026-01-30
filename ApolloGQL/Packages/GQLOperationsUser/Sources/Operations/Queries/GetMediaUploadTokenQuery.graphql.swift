// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMediaUploadTokenQuery: GraphQLQuery {
  public static let operationName: String = "GetMediaUploadToken"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMediaUploadToken { postEligibility { __typename meta { __typename status RequestId ResponseCode ResponseMessage } eligibilityToken } }"#
    ))

  public init() {}

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("postEligibility", PostEligibility.self),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetMediaUploadTokenQuery.Data.self
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
        .field("meta", Meta.self),
        .field("eligibilityToken", String.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetMediaUploadTokenQuery.Data.PostEligibility.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var eligibilityToken: String { __data["eligibilityToken"] }

      /// PostEligibility.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", String.self),
          .field("RequestId", String?.self),
          .field("ResponseCode", String?.self),
          .field("ResponseMessage", String?.self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetMediaUploadTokenQuery.Data.PostEligibility.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String? { __data["RequestId"] }
        @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
        public var responseCode: String? { __data["ResponseCode"] }
        public var responseMessage: String? { __data["ResponseMessage"] }
      }
    }
  }
}
