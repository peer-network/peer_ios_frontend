//
//  PostsListView.swift
//  FeedList
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem
import Models
import Post

public struct PostsListView<Fetcher>: View where Fetcher: PostsFetcher {
    @StateObject private var fetcher: Fetcher

    private let displayType: PostView.DisplayType
    private let showFollowButton: Bool

    public init(fetcher: Fetcher, displayType: PostView.DisplayType, showFollowButton: Bool) {
        _fetcher = .init(wrappedValue: fetcher)
        self.displayType = displayType
        self.showFollowButton = showFollowButton
    }

    public var body: some View {
        switch fetcher.state {
            case .loading:
                ForEach(Post.placeholdersImage(count: 5)) { post in
                    PostView(postVM: PostViewModel(post: post), displayType: displayType, showFollowButton: showFollowButton)
                        .skeleton(isRedacted: true)
                        .allowsHitTesting(false)
                }
            case .display(let posts, let hasMore):
                if posts.isEmpty {
                    Text("No posts yet...")
                        .padding(20)
                } else {
                    ForEach(posts) { post in
                        PostView(postVM: PostViewModel(post: post), displayType: displayType, showFollowButton: showFollowButton)
                            .id(post.refreshID)
                    }

                    switch hasMore {
                        case .hasMore:
                            NextPageView {
                                await fetcher.fetchPosts(reset: false)
                            }
                            .padding(.horizontal, 20)
                        case .none:
                            EmptyView()
                    }
                }
            case .error(let error):
                ErrorView(title: "Error", description: error.userFriendlyDescription) {
                    Task {
                        await fetcher.fetchPosts(reset: true)
                    }
                }
                .padding(20)
        }
    }
}
