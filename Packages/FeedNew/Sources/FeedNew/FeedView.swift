//
//  FeedView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Environment
import DesignSystem
import Analytics

public struct FeedView: View {
    @Environment(\.analytics) private var analytics
    
    @EnvironmentObject private var audioManager: AudioSessionManager

    @State private var feedPage: FeedPage = .normalFeed

    // Filters properties
    @State private var showFilters = false
    @State private var filtersPosition: CGRect = .zero

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            headerView
        } content: {
            VStack(alignment: .center, spacing: 0) {
                FeedTabControllerView(feedPage: $feedPage)

                TabView(selection: $feedPage) {
                    NormalFeedView()
                        .tag(FeedPage.normalFeed)
                        .trackScreen(AppScreen.photoAndTextFeed)

                    ReelsMainView()
                        .tag(FeedPage.videoFeed)
                        .onAppear {
                            audioManager.isInRestrictedView = true
                        }
                        .onDisappear {
                            audioManager.isInRestrictedView = false
                        }
                        .trackScreen(AppScreen.videoFeed)

                    AudioFeedView()
                        .tag(FeedPage.audioFeed)
                        .trackScreen(AppScreen.audioFeed)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .background {
            Colors.textActive
                .ignoresSafeArea(.all)
        }
        .overlay(alignment: .topLeading) {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            showFilters = false
                        }
                    }
                    .allowsHitTesting(showFilters)

                ZStack {
                    if showFilters {
                        SortingPopupView()
                            .transition(.blurReplace)
                    }
                }
                .offset(x: 20, y: filtersPosition.maxY + 10)
            }
            .ignoresSafeArea()
        }
        .onAppear {
//            print("😘 \(type(of: self))")
        }
        .trackScreen(AppScreen.feed)
    }

    private struct NormalFeedView: View {
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
                        PostsListView(fetcher: normalFeedVM)
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

    private struct AudioFeedView: View {
        @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop
        @EnvironmentObject private var router: Router
        @EnvironmentObject private var apiManager: APIServiceManager

        @StateObject private var feedContentSortingAndFiltering = FeedContentSortingAndFiltering.shared

        @StateObject private var audioFeedVM = AudioFeedViewModel()

        var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .center, spacing: 20) {
                        PostsListView(fetcher: audioFeedVM)
                    }
                    .padding(.bottom, 10)
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

    @ViewBuilder
    private var headerView: some View {
        Button {
            //
        } label: {
            Button {
                withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                    showFilters.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Text("Feed")

                    Icons.arrowDown
                        .iconSize(height: 7)
                }
                .contentShape(Rectangle())
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .global)
                } action: { newValue in
                    filtersPosition = newValue
                }
            }
        }
    }
}
