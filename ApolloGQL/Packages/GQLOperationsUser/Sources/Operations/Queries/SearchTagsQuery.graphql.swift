// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchTagsQuery: GraphQLQuery {
  public static let operationName: String = "SearchTags"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchTags($tagname: String!, $offset: Int, $limit: Int) { tagsearch(tagname: $tagname, offset: $offset, limit: $limit) { __typename status counter ResponseCode affectedRows { __typename name } } }"#
    ))

  public var tagname: String
  public var offset: GraphQLNullable<Int>
  public var limit: GraphQLNullable<Int>

  public init(
    tagname: String,
    offset: GraphQLNullable<Int>,
    limit: GraphQLNullable<Int>
  ) {
    self.tagname = tagname
    self.offset = offset
    self.limit = limit
  }

  public var __variables: Variables? { [
    "tagname": tagname,
    "offset": offset,
    "limit": limit
  ] }

  public struct Data: GQLOperationsUser.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GQLOperationsUser.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("tagsearch", Tagsearch.self, arguments: [
        "tagname": .variable("tagname"),
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }

    public var tagsearch: Tagsearch { __data["tagsearch"] }

    /// Tagsearch
    ///
    /// Parent Type: `TagSearchResponse`
    public struct Tagsearch: GQLOperationsUser.SelectionSet {
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

      public var status: String { __data["status"] }
      public var counter: Int { __data["counter"] }
      public var responseCode: String? { __data["ResponseCode"] }
      public var affectedRows: [AffectedRow?]? { __data["affectedRows"] }

      /// Tagsearch.AffectedRow
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
