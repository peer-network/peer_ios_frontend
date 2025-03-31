//
//  PostsFetcher.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import Models
import Combine

public enum PostsState {
    public enum PagingState {
        case hasMore, none
    }
    
    case loading
    case display(posts: [Post], hasMore: PostsState.PagingState)
    case error(error: Error)
}

@MainActor
public protocol PostsFetcher: ObservableObject {
    var state: PostsState { get }
    func fetchPosts(reset: Bool) async
}
