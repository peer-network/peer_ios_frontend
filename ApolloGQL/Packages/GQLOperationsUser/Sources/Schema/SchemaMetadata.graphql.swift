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
    case "BlockedUser": return GQLOperationsUser.Objects.BlockedUser
    case "BlockedUsers": return GQLOperationsUser.Objects.BlockedUsers
    case "BlockedUsersResponse": return GQLOperationsUser.Objects.BlockedUsersResponse
    case "Comment": return GQLOperationsUser.Objects.Comment
    case "CommentResponse": return GQLOperationsUser.Objects.CommentResponse
    case "CurrentLiquidity": return GQLOperationsUser.Objects.CurrentLiquidity
    case "DailyFreeResponse": return GQLOperationsUser.Objects.DailyFreeResponse
    case "DefaultResponse": return GQLOperationsUser.Objects.DefaultResponse
    case "FollowRelations": return GQLOperationsUser.Objects.FollowRelations
    case "FollowRelationsResponse": return GQLOperationsUser.Objects.FollowRelationsResponse
    case "FollowStatusResponse": return GQLOperationsUser.Objects.FollowStatusResponse
    case "GetDailyResponse": return GQLOperationsUser.Objects.GetDailyResponse
    case "HelloResponse": return GQLOperationsUser.Objects.HelloResponse
    case "Mutation": return GQLOperationsUser.Objects.Mutation
    case "Post": return GQLOperationsUser.Objects.Post
    case "PostListResponse": return GQLOperationsUser.Objects.PostListResponse
    case "PostResponse": return GQLOperationsUser.Objects.PostResponse
    case "Profile": return GQLOperationsUser.Objects.Profile
    case "ProfileInfo": return GQLOperationsUser.Objects.ProfileInfo
    case "ProfileUser": return GQLOperationsUser.Objects.ProfileUser
    case "Query": return GQLOperationsUser.Objects.Query
    case "ReferralInfoResponse": return GQLOperationsUser.Objects.ReferralInfoResponse
    case "ReferralListResponse": return GQLOperationsUser.Objects.ReferralListResponse
    case "ReferralUsers": return GQLOperationsUser.Objects.ReferralUsers
    case "Tag": return GQLOperationsUser.Objects.Tag
    case "TagSearchResponse": return GQLOperationsUser.Objects.TagSearchResponse
    case "User": return GQLOperationsUser.Objects.User
    case "UserFriendsResponse": return GQLOperationsUser.Objects.UserFriendsResponse
    case "UserListResponse": return GQLOperationsUser.Objects.UserListResponse
    case "Userinfo": return GQLOperationsUser.Objects.Userinfo
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
