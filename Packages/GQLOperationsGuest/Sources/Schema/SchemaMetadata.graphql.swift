// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GQLOperationsGuest.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GQLOperationsGuest.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GQLOperationsGuest.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GQLOperationsGuest.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "AuthPayload": return GQLOperationsGuest.Objects.AuthPayload
    case "DefaultResponse": return GQLOperationsGuest.Objects.DefaultResponse
    case "HelloResponse": return GQLOperationsGuest.Objects.HelloResponse
    case "Mutation": return GQLOperationsGuest.Objects.Mutation
    case "Query": return GQLOperationsGuest.Objects.Query
    case "ReferralResponse": return GQLOperationsGuest.Objects.ReferralResponse
    case "RegisterResponse": return GQLOperationsGuest.Objects.RegisterResponse
    case "ResetPasswordRequestResponse": return GQLOperationsGuest.Objects.ResetPasswordRequestResponse
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
