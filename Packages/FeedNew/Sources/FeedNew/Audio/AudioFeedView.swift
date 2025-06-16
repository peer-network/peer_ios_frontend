//
//  AudioFeedView.swift
//  FeedNew
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import Environment
import DesignSystem
import FeedList

struct AudioFeedView: View {
    @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var feedContentSortingAndFiltering = FeedContentSortingAndFiltering.shared

    @StateObject private var audioFeedVM = AudioFeedViewModel()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .center, spacing: 20) {
                    PostsListView(fetcher: audioFeedVM, displayType: .list, showFollowButton: true)
                }
                .padding(.vertical, 10)
                .geometryGroup()
            }
            .refreshable {
                HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                audioFeedVM.fetchPosts(reset: true)
            }
            .onChange(of: selectedTabScrollToTop) {
                if selectedTabScrollToTop == 0, router.path.isEmpty {
                    withAnimation {
                        proxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                    }
                }
            }
            .onFirstAppear {
                audioFeedVM.apiService = apiManager.apiService
                audioFeedVM.fetchPosts(reset: true)
            }
            .onChange(of: feedContentSortingAndFiltering.filterByRelationship) {
                guard audioFeedVM.apiService != nil else {
                    return
                }
                audioFeedVM.fetchPosts(reset: true)
            }
            .onChange(of: feedContentSortingAndFiltering.sortByPopularity) {
                guard audioFeedVM.apiService != nil else {
                    return
                }
                audioFeedVM.fetchPosts(reset: true)
            }
            .onChange(of: feedContentSortingAndFiltering.sortByTime) {
                guard audioFeedVM.apiService != nil else {
                    return
                }
                audioFeedVM.fetchPosts(reset: true)
            }
        }
    }
}
