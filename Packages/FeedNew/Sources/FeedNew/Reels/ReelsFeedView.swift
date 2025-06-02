//
//  ReelsFeedView.swift
//  FeedNew
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import Environment
import DesignSystem
import FeedList

struct ReelsFeedView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel = VideoFeedViewModel()
    @StateObject private var feedContentSortingAndFiltering = FeedContentSortingAndFiltering.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    PostsListView(fetcher: viewModel, displayType: .list, showFollowButton: true)
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .refreshable {
                HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                viewModel.fetchPosts(reset: true)
            }
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.filterByRelationship) {
            guard viewModel.apiService != nil else {
                return
            }
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.sortByPopularity) {
            guard viewModel.apiService != nil else {
                return
            }
            viewModel.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.sortByTime) {
            guard viewModel.apiService != nil else {
                return
            }
            viewModel.fetchPosts(reset: true)
        }
    }
}
