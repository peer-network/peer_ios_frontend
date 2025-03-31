// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateAvatarMutation: GraphQLMutation {
  public static let operationName: String = "UpdateAvatar"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateAvatar($img: String!) { updateProfilePicture(img: $img) { __typename status ResponseCode } }"#
    ))

  public var img: String

  public init(img: String) {
    self.img = img
  }

  public var __variables: Variables? { ["img": img] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateProfilePicture", UpdateProfilePicture.self, arguments: ["img": .variable("img")]),
    ] }

    public var updateProfilePicture: UpdateProfilePicture { __data["updateProfilePicture"] }

    /// UpdateProfilePicture
    ///
    /// Parent Type: `DefaultResponse`
    public struct UpdateProfilePicture: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.DefaultResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("ResponseCode", String?.self),
      ] }

      public var status: String { __data["status"] }
      public var responseCode: String? { __data["ResponseCode"] }
    }
  }
}
