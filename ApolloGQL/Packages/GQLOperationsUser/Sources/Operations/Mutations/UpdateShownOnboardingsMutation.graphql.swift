// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateShownOnboardingsMutation: GraphQLMutation {
  public static let operationName: String = "UpdateShownOnboardings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateShownOnboardings($shownOnboardings: [OnboardingType!]!) { updateUserPreferences(userPreferences: { shownOnboardings: $shownOnboardings }) { __typename meta { __typename status RequestId ResponseCode ResponseMessage } affectedRows { __typename onboardingsWereShown } } }"#
    ))

  public var shownOnboardings: [GraphQLEnum<OnboardingType>]

  public init(shownOnboardings: [GraphQLEnum<OnboardingType>]) {
    self.shownOnboardings = shownOnboardings
  }

  public var __variables: Variables? { ["shownOnboardings": shownOnboardings] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateUserPreferences", UpdateUserPreferences.self, arguments: ["userPreferences": ["shownOnboardings": .variable("shownOnboardings")]]),
    ] }
    public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdateShownOnboardingsMutation.Data.self
    ] }

    public var updateUserPreferences: UpdateUserPreferences { __data["updateUserPreferences"] }

    /// UpdateUserPreferences
    ///
    /// Parent Type: `UserPreferencesResponse`
    public struct UpdateUserPreferences: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserPreferencesResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("meta", Meta.self),
        .field("affectedRows", AffectedRows?.self),
      ] }
      public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateShownOnboardingsMutation.Data.UpdateUserPreferences.self
      ] }

      public var meta: Meta { __data["meta"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

      /// UpdateUserPreferences.Meta
      ///
      /// Parent Type: `DefaultResponse`
      public struct Meta: GQLOperationsUser.SelectionSet {
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
          UpdateShownOnboardingsMutation.Data.UpdateUserPreferences.Meta.self
        ] }

        public var status: String { __data["status"] }
        public var requestId: String { __data["RequestId"] }
        public var responseCode: String { __data["ResponseCode"] }
        public var responseMessage: String { __data["ResponseMessage"] }
      }

      /// UpdateUserPreferences.AffectedRows
      ///
      /// Parent Type: `UserPreferences`
      public struct AffectedRows: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.UserPreferences }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("onboardingsWereShown", [GraphQLEnum<GQLOperationsUser.OnboardingType>].self),
        ] }
        public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateShownOnboardingsMutation.Data.UpdateUserPreferences.AffectedRows.self
        ] }

        public var onboardingsWereShown: [GraphQLEnum<GQLOperationsUser.OnboardingType>] { __data["onboardingsWereShown"] }
      }
    }
  }
}
