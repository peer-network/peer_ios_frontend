//
//  SearchViewModelTags.swift
//  PeerApp
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import Models

@MainActor
final class SearchViewModelTags: ObservableObject {
    public unowned var apiService: (any APIService)!
    
    private var fetchTagsTask: Task<Void, Never>?
    private var fetchPostsTask: Task<Void, Never>?

    @Published var tags: [String] = []
    @Published var posts: [Post] = []

    private var currentOffsetPosts: Int = 0
    private var hasMorePosts: Bool = true

    func fetchTags(reset: Bool, tag: String) async {
        if let existingTask = fetchTagsTask, !existingTask.isCancelled {
            existingTask.cancel()
        }

        if reset {
            tags = []
        }

        fetchTagsTask = Task {
            do {
                let result = await apiService.fetchTags(with: tag)
                
                try Task.checkCancellation()
                
                switch result {
                case .success(let fetchedTags):
                    tags.append(contentsOf: fetchedTags)
                case .failure(let apiError):
                    throw apiError
                }
            } catch {

            }
            
            fetchTagsTask = nil
        }
    }

    func fetchPosts(reset: Bool, tag: String) async {
        if let existingTask = fetchPostsTask, !existingTask.isCancelled {
            existingTask.cancel()
        }

        if reset {
            posts.removeAll()
            hasMorePosts = true
            currentOffsetPosts = 0
        }

        fetchPostsTask = Task {
            do {
                let result = await apiService.fetchPostsByTag(tag, after: currentOffsetPosts)
                
                try Task.checkCancellation()
                
                switch result {
                case .success(let fetchedPosts):
                    posts.append(contentsOf: fetchedPosts)

                    if fetchedPosts.count != 20 {
                        hasMorePosts = false
                    } else {
                        currentOffsetPosts += 20
                        hasMorePosts = true
                    }
                case .failure(let apiError):
                    throw apiError
                }
            } catch {

            }
            fetchPostsTask = nil
        }
    }
}
