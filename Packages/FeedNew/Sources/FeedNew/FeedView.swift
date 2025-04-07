//
//  FeedView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Environment
import DesignSystem

public struct FeedView: View {
    @EnvironmentObject private var accountManager: AccountManager
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

                    ReelsMainView()
                        .tag(FeedPage.videoFeed)
                        .onAppear {
                            audioManager.isInRestrictedView = true
                        }
                        .onDisappear {
                            audioManager.isInRestrictedView = false
                        }

                    AudioFeedView()
                        .tag(FeedPage.audioFeed)
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

    }

    private struct NormalFeedView: View {
        @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop
        @EnvironmentObject private var router: Router
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
                    await normalFeedVM.fetchPosts(reset: true)
                }
                .onChange(of: selectedTabScrollToTop) {
                    if selectedTabScrollToTop == 0, router.path.isEmpty {
                        withAnimation {
                            proxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                        }
                    }
                }
            }
            .onChange(of: feedContentSortingAndFiltering.filterByRelationship) {
                Task {
                    await normalFeedVM.fetchPosts(reset: true)
                }
            }
            .onChange(of: feedContentSortingAndFiltering.sortByPopularity) {
                Task {
                    await normalFeedVM.fetchPosts(reset: true)
                }
            }
            .onChange(of: feedContentSortingAndFiltering.sortByTime) {
                Task {
                    await normalFeedVM.fetchPosts(reset: true)
                }
            }
        }
    }

    private struct AudioFeedView: View {
        @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop
        @EnvironmentObject private var router: Router
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
                    await audioFeedVM.fetchPosts(reset: true)
                }
                .onChange(of: selectedTabScrollToTop) {
                    if selectedTabScrollToTop == 0, router.path.isEmpty {
                        withAnimation {
                            proxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                        }
                    }
                }
            }
            .onChange(of: feedContentSortingAndFiltering.filterByRelationship) {
                Task {
                    await audioFeedVM.fetchPosts(reset: true)
                }
            }
            .onChange(of: feedContentSortingAndFiltering.sortByPopularity) {
                Task {
                    await audioFeedVM.fetchPosts(reset: true)
                }
            }
            .onChange(of: feedContentSortingAndFiltering.sortByTime) {
                Task {
                    await audioFeedVM.fetchPosts(reset: true)
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
//                .overlay(
//                    GeometryReader { proxy in
//                        Color.clear.preference(key: OffsetKeyRect.self, value: proxy.frame(in: .global))
//                    }
//                )
//                .onPreferenceChange(OffsetKeyRect.self) { value in
//                    filtersPosition = value
//                }
            }
        }
    }
}
