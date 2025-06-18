//
//  AudioFeedViewModel.swift
//  FeedNew
//
//  Created by Артем Васин on 09.02.25.
//

import SwiftUI
import Models
import Environment
import FeedList

@MainActor
public final class AudioFeedViewModel: ObservableObject, PostsFetcher {
    public unowned var apiService: APIService!
    
    @Published public private(set) var state = PostsState.loading

    private var userId: String?

    private var fetchTask: Task<Void, Never>?
    
    private var currentOffset: Int = 0
    private var hasMorePosts: Bool = true
    private var posts: [Post] = []
    
    public init(userId: String? = nil) {
        self.userId = userId
    }

    public func fetchPosts(reset: Bool) {
        if let existingTask = fetchTask, !existingTask.isCancelled {
            if reset {
                // Cancel and start a fresh fetch for reset scenarios
                existingTask.cancel()
            } else {
                // Do not run a new task if there is already a task running
                return
            }
        }
        
        if reset {
            if posts.isEmpty {
                state = .loading
            }

            currentOffset = 0
            hasMorePosts = true
        }
        
        fetchTask = Task {
            do {
                let sort = FeedContentSortingAndFiltering.shared.sortByPopularity
                let filter = FeedContentSortingAndFiltering.shared.filterByRelationship
                let inTimeframe = FeedContentSortingAndFiltering.shared.sortByTime
                let result = await apiService.fetchPosts(
                    with: .audio,
                    sort: sort,
                    showHiddenContent: false,
                    filter: filter,
                    in: inTimeframe,
                    after: currentOffset,
                    for: userId,
                    amount: Constants.postsFetchLimit
                )
                
                try Task.checkCancellation()
                
                switch result {
                case .success(let fetchedPosts):
                    if reset {
                        posts.removeAll()
                    }

                    posts.append(contentsOf: fetchedPosts)
                    
                    if fetchedPosts.count != Constants.postsFetchLimit {
                        hasMorePosts = false
                        state = .display(posts: posts, hasMore: .none)
                    } else {
                        currentOffset += Constants.postsFetchLimit
                        state = .display(posts: posts, hasMore: .hasMore)
                    }
                case .failure(let apiError):
                    throw apiError
                }
            } catch is CancellationError {
//                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                state = .error(error: error)
                posts = []
            }
            
            // Reset fetchTask to nil when done
            fetchTask = nil
        }
    }
}
