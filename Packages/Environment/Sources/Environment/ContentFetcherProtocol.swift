//
//  ContentFetcherProtocol.swift
//  Environment
//
//  Created by Artem Vasin on 25.04.25.
//

// For content with pagination
public enum PagingState {
    case hasMore, none
}

public enum PaginatedContentState<Content> {
    case loading(placeholder: Content)
    case display(content: Content, hasMore: PagingState)
    case error(error: Error)
}

// For simple content without pagination
public enum ContentState<Content> {
    case loading(placeholder: Content)
    case display(content: Content)
    case error(error: Error)
}

// For paginated content
@MainActor
public protocol PaginatedContentFetcher {
    associatedtype Content
    var state: PaginatedContentState<Content> { get }
    func fetchContent(reset: Bool)
}

// For simple content
@MainActor
public protocol SimpleContentFetcher {
    associatedtype Content
    var state: ContentState<Content> { get }
    func fetchContent()
}
