//
//  PostsListView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

public struct PostsListView<Fetcher>: View where Fetcher: PostsFetcher {
    @EnvironmentObject private var router: Router

    @StateObject private var fetcher: Fetcher

    public init(fetcher: Fetcher) {
        _fetcher = .init(wrappedValue: fetcher)
    }

    public var body: some View {
        switch fetcher.state {
            case .loading:
                    ForEach(0..<10, id: \.self) { _ in
                        PostView(postVM: PostViewModel(post: Post.placeholderText())) // also pass router
                            .redacted(reason: .placeholder)
                            .allowsHitTesting(false)
                    }
            case .display(let posts, let hasMore):
                if posts.isEmpty {
                    Text("No posts yet...")
                        .padding(20)
                } else {
                    ForEach(posts) { post in
                        PostView(postVM: PostViewModel(post: post))
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
                ErrorView(
                    title: "An error occurred",
                    message: "An error occurred while loading posts, please try again.",
                    //                    message: "\(error.localizedDescription)",
                    buttonTitle: "Retry"
                ) {
                    await fetcher.fetchPosts(reset: true)
                }
        }
    }
}
