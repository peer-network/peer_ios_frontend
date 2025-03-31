// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GQLOperationsUser.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GQLOperationsUser.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GQLOperationsUser.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GQLOperationsUser.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Comment": return GQLOperationsUser.Objects.Comment
    case "CommentResponse": return GQLOperationsUser.Objects.CommentResponse
    case "CurrentLiquidity": return GQLOperationsUser.Objects.CurrentLiquidity
    case "DailyResponse": return GQLOperationsUser.Objects.DailyResponse
    case "DefaultResponse": return GQLOperationsUser.Objects.DefaultResponse
    case "Followes": return GQLOperationsUser.Objects.Followes
    case "GetAllPostResponse": return GQLOperationsUser.Objects.GetAllPostResponse
    case "GetDailyResponse": return GQLOperationsUser.Objects.GetDailyResponse
    case "HelloResponse": return GQLOperationsUser.Objects.HelloResponse
    case "Mutation": return GQLOperationsUser.Objects.Mutation
    case "Post": return GQLOperationsUser.Objects.Post
    case "PostResponse": return GQLOperationsUser.Objects.PostResponse
    case "ProfilUser": return GQLOperationsUser.Objects.ProfilUser
    case "Profile": return GQLOperationsUser.Objects.Profile
    case "ProfileInfo": return GQLOperationsUser.Objects.ProfileInfo
    case "Query": return GQLOperationsUser.Objects.Query
    case "Tag": return GQLOperationsUser.Objects.Tag
    case "TagSearchResponse": return GQLOperationsUser.Objects.TagSearchResponse
    case "User": return GQLOperationsUser.Objects.User
    case "UserFollows": return GQLOperationsUser.Objects.UserFollows
    case "UserFriends": return GQLOperationsUser.Objects.UserFriends
    case "UserSearchResponse": return GQLOperationsUser.Objects.UserSearchResponse
    case "Userinfo": return GQLOperationsUser.Objects.Userinfo
    case "setFollowUseresponse": return GQLOperationsUser.Objects.SetFollowUseresponse
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
