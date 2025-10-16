// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchTagsQuery: GraphQLQuery {
  public static let operationName: String = "SearchTags"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchTags($tagName: String!, $offset: Int, $limit: Int) { searchTags(tagName: $tagName, offset: $offset, limit: $limit) { __typename status counter ResponseCode affectedRows { __typename name } } }"#
    ))

  public var tagName: String
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    tagName: String,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.tagName = tagName
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "tagName": tagName,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchTags", SearchTags.self, arguments: [
        "tagName": .variable("tagName"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var searchTags: SearchTags { __data["searchTags"] }

    /// SearchTags
    ///
    /// Parent Type: `TagSearchResponse`
    public struct SearchTags: GQLOperationsUser.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.TagSearchResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("status", String.self),
        .field("counter", Int.self),
        .field("ResponseCode", String?.self),
        .field("affectedRows", [AffectedRow?]?.self),
      ] }

      @available(*, deprecated, message: "use meta.status . this field will be removed after 15 October`.")
      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      @available(*, deprecated, message: "use meta.ResponseCode . this field will be removed after 15 October`.")
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// SearchTags.AffectedRow
      ///
      /// Parent Type: `Tag`
      public struct AffectedRow: GQLOperationsUser.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Tag }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        public var name: String { __data["name"] }
      }
    }
  }
}
