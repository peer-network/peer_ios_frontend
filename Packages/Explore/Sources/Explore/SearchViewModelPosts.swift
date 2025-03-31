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
                let operation = GetAllPostsQuery(filterBy: [.case(.image), .case(.text), .case(.video), .case(.audio)], ignorList: .some(.case(.no)), sortBy: .some(.case(.newest)), title: GraphQLNullable(stringLiteral: title.lowercased()), tag: nil, from: nil, to: nil, postOffset: GraphQLNullable<Int>(integerLiteral: currentOffsetPosts), postLimit: 20, commentOffset: nil, commentLimit: nil, postid: nil, userid: nil)

                let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

                guard let values = result.getallposts.affectedRows else {
                    throw GQLError.missingData
                }

                try Task.checkCancellation()

                let fetchedPosts = values.compactMap { value in
                    Post(gqlPost: value)
                }

                posts.append(contentsOf: fetchedPosts)

                if fetchedPosts.count != 20 {
                    hasMorePosts = false
                } else {
                    currentOffsetPosts += 20
                    hasMorePosts = true
                }
            } catch {

            }
        }
    }
}
