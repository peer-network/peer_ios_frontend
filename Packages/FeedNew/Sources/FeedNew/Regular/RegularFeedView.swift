//
//  RegularFeedView.swift
//  FeedNew
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import Environment
import DesignSystem
import FeedList

struct RegularFeedView: View {
    @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager
    @StateObject private var normalFeedVM = NormalFeedViewModel()
    @StateObject private var feedContentSortingAndFiltering = FeedContentSortingAndFiltering.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ScrollToView()
                LazyVStack(spacing: 20) {
                    PostsListView(fetcher: normalFeedVM, displayType: .list, showFollowButton: true)
                }
                .padding(.bottom, 10)
            }
            .refreshable {
                HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                normalFeedVM.fetchPosts(reset: true)
            }
            .onChange(of: selectedTabScrollToTop) {
                if selectedTabScrollToTop == 0, router.path.isEmpty {
                    withAnimation {
                        proxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                    }
                }
            }
        }
        .onFirstAppear {
            normalFeedVM.apiService = apiManager.apiService
            normalFeedVM.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.filterByRelationship) {
            guard normalFeedVM.apiService != nil else {
                return
            }
            normalFeedVM.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.sortByPopularity) {
            guard normalFeedVM.apiService != nil else {
                return
            }
            normalFeedVM.fetchPosts(reset: true)
        }
        .onChange(of: feedContentSortingAndFiltering.sortByTime) {
            guard normalFeedVM.apiService != nil else {
                return
            }
            normalFeedVM.fetchPosts(reset: true)
        }
    }
}
