//
//  SearchViewModelTags.swift
//  PeerApp
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import Models
import Networking
import GQLOperationsUser

@MainActor
final class SearchViewModelTags: ObservableObject {
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
                let operation = SearchTagsQuery(tagname: tag, offset: 0, limit: 20)

                let result = try await GQLClient.shared.fetch(query: operation, cachePolicy: .fetchIgnoringCacheCompletely)

                guard let values = result.tagsearch.affectedRows else {
                    throw GQLError.missingData
                }

                try Task.checkCancellation()

                let fetchedTags = values.compactMap { value in
                    value?.name
                }

                tags.append(contentsOf: fetchedTags)
            } catch {

            }
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
                let operation = GetAllPostsQuery(filterBy: [.case(.image), .case(.text), .case(.video), .case(.audio)], ignorList: .some(.case(.no)), sortBy: .some(.case(.newest)), title: nil, tag: GraphQLNullable(stringLiteral: tag.lowercased()), from: nil, to: nil, postOffset: GraphQLNullable<Int>(integerLiteral: currentOffsetPosts), postLimit: 20, commentOffset: nil, commentLimit: nil, postid: nil, userid: nil)

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
