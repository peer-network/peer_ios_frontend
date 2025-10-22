// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateShownOnboardingsMutation: GraphQLMutation {
  public static let operationName: String = "UpdateShownOnboardings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateShownOnboardings($shownOnboardings: [OnboardingType!]!) { updateUserPreferences(userPreferences: { shownOnboardings: $shownOnboardings }) { __typename status ResponseCode affectedRows { __typename onboardingsWereShown } } }"#
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
        .field("status", String.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", AffectedRows?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: AffectedRows? { __data["affectedRows"] }

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

        public var onboardingsWereShown: [GraphQLEnum<GQLOperationsUser.OnboardingType>] { __data["onboardingsWereShown"] }
      }
    }
  }
}
