//
//  ReelsView.swift
//  FeedNew
//
//  Created by Артем Васин on 07.02.25.
//

import SwiftUI
import Models
import Environment
import DesignSystem

struct ReelsView: View {
    var size: CGSize
    
    @State private var posts: [Post] = Post.placeholders()
    @State private var likedCounter: [ReelLike] = []

    @StateObject private var feedContentSortingAndFiltering = FeedContentSortingAndFiltering.shared

    @StateObject private var viewModel = VideoFeedViewModel()
    @EnvironmentObject private var apiManager: APIServiceManager

    var body: some View {
        ScrollView(.vertical) {
            switch viewModel.state {
                case .loading:
                    EmptyView()
                case .display(let posts, let hasMore):
                    LazyVStack(spacing: 0) {
                        ForEach(posts) { post in
                            ReelView(
                                likedCounter: $likedCounter,
                                size: size
                            )
                            .frame(maxWidth: .infinity)
                            .containerRelativeFrame(.vertical)
                            .environmentObject(PostViewModel(post: post))
                        }
                    }
                case .error(let error):
                    EmptyView()
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .background(Color.backgroundDark)
        /// Like Animation View
        .overlay(alignment: .topLeading) {
            ZStack {
                ForEach(likedCounter) { like in
                    Icons.heartFill
                        .iconSize(height: 80)
                        .foregroundStyle(Color.redAccent)
                        .frame(width: 100, height: 100)
                    /// Adding Some Implicit Rotation & Scaling Animation
                        .animation(.smooth, body: { view in
                            view
                                .scaleEffect(like.isAnimated ? 1 : 1.8)
                                .rotationEffect(.init(degrees: like.isAnimated ? 0 : .random(in: -30...30)))
                        })
                        .offset(x: like.tappedRect.x - 40, y: like.tappedRect.y - 40)
                    /// Let's Animate
                        .offset(y: like.isAnimated ? -(like.tappedRect.y + 50) : 0)
                }
            }
        }
        .onAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.fetchPosts(reset: true)
        }
        .refreshable {
            HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.filterByRelationship) {
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.sortByPopularity) {
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.sortByTime) {
            viewModel.fetchPosts(reset: true)
        }
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    ReelsMainView()
        .environmentObject(PostViewModel(post: .placeholderText()))
}
