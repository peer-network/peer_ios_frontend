//
//  NormalFeedViewModel.swift
//  FeedNew
//
//  Created by Артем Васин on 09.02.25.
//

import SwiftUI
import Models
import Networking
import GQLOperationsUser

@MainActor
public final class NormalFeedViewModel: ObservableObject, PostsFetcher {
    @Published public private(set) var state = PostsState.loading

    private var userId: String?

    private var fetchTask: Task<Void, Never>?
    
    private var currentOffset: Int = 0
    private var hasMorePosts: Bool = true
    private var posts: [Post] = []
    
    public init(userId: String? = nil) {
        self.userId = userId
        Task {
            await fetchPosts(reset: true)
        }
    }
    
    public func fetchPosts(reset: Bool) async {
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
                let sortBy = FeedContentSortingAndFiltering.shared.sortByPopularity.apiValue

                var filterBy: GraphQLNullable<[GraphQLEnum<FilterType>]>
                let filterByAddition = FeedContentSortingAndFiltering.shared.filterByRelationship.apiValue
                if let filterByAddition {
                    filterBy = [.case(.image), .case(.text), filterByAddition]
                } else {
                    filterBy = [.case(.image), .case(.text)]
                }

                let timeSorting = FeedContentSortingAndFiltering.shared.sortByTime
                let timeFrom = timeSorting.apiValue.0
                let timeTo = timeSorting.apiValue.1

                let operation = GetAllPostsQuery(
                    filterBy: filterBy,
                    ignorList: .some(.case(.yes)),
                    sortBy: sortBy,
                    title: nil,
                    tag: nil,
                    from: timeFrom != nil ? GraphQLNullable(stringLiteral: timeFrom!) : nil,
                    to: timeTo != nil ? GraphQLNullable(stringLiteral: timeTo!) : nil,
                    postOffset: GraphQLNullable<Int>(integerLiteral: currentOffset),
                    postLimit: GraphQLNullable<Int>(integerLiteral: Constants.postsFetchLimit),
                    commentOffset: 0,
                    commentLimit: 0,
                    postid: nil,
                    userid: userId == nil ? nil : GraphQLNullable(stringLiteral: userId!)
                )

                let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)
                
                guard let values = result.getallposts.affectedRows else {
                    throw GQLError.missingData
                }

                try Task.checkCancellation()
                
                let fetchedPosts = values.compactMap { value in
                    Post(gqlPost: value)
                }

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
