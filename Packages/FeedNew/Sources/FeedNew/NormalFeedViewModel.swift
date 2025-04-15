//
//  NormalFeedViewModel.swift
//  FeedNew
//
//  Created by Артем Васин on 09.02.25.
//

import SwiftUI
import Models
import Environment
import Combine

@MainActor
public final class NormalFeedViewModel: ObservableObject, PostsFetcher {
    public struct Transitions: PostNavigator {
        public let openProfile: (String) -> Void
        public let showComments: (Models.Post) -> Void
        
        public init(openProfile: @escaping (String) -> Void, showComments: @escaping (Models.Post) -> Void) {
            self.openProfile = openProfile
            self.showComments = showComments
        }
    }
    
    public var openProfile: (String) -> Void {
        self.transitions.openProfile
    }
    
    public var showComments: (Models.Post) -> Void {
        self.transitions.showComments
    }
    
    public unowned var apiService: APIService!
    @ObservedObject var filters: FeedContentSortingAndFiltering
    public let transitions: Transitions
    @Published public private(set) var state = PostsState.loading

    private let feedContentType: FeedContentType

    private var userId: String?

    private var fetchTask: Task<Void, Never>?
    
    private var currentOffset: Int = 0
    private var hasMorePosts: Bool = true
    private var posts: [Post] = []
    
    private var filterSubscription: AnyCancellable?
    
    public init(
        userId: String? = nil,
        feedType: FeedContentType,
        apiService: APIService,
        filters: FeedContentSortingAndFiltering,
        transitions: Transitions
    ) {
        self.userId = userId
        self.feedContentType = feedType
        self.apiService = apiService
        self.filters = filters
        self.transitions = transitions
    }
    
    func onAppear() {
        guard filterSubscription == nil else { return }
        filterSubscription = self.filters.objectWillChange
            .sink { [weak self] _ in
                self?.fetchPosts(reset: true)
            }
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
                let sort = filters.sortByPopularity
                let filter = filters.filterByRelationship
                let inTimeframe = filters.sortByTime
                let result = await apiService.fetchPosts(
                    with: feedContentType,
                    sort: sort,
                    filter: filter,
                    in: inTimeframe,
                    after: currentOffset,
                    for: userId
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
