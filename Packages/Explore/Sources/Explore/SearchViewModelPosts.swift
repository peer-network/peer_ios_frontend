//
//  SearchViewModelPosts.swift
//  PeerApp
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import Models
import Networking
import GQLOperationsUser

@MainActor
final class SearchViewModelPosts: ObservableObject {
    public unowned var apiService: (any APIService)!
    private var fetchPostsTask: Task<Void, Never>?

    @Published var posts: [Post] = []

    private var currentOffsetPosts: Int = 0
    private var hasMorePosts: Bool = true

    func fetchPosts(reset: Bool, title: String) async {
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
                let result = await apiService.fetchPostsByTitle(title.lowercased(), after: currentOffsetPosts)
                
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
