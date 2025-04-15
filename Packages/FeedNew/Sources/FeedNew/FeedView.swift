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
    @EnvironmentObject private var audioManager: AudioSessionManager
    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var router: Router
    
    @State private var feedPage: FeedPage = .normalFeed

    // Filters properties
    @State private var showFilters = false
    @State private var filtersPosition: CGRect = .zero

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            headerView
        } content: {
            let openProfile = { userID in
                router .navigate(to: .accountDetail(id: userID))
            }
            
            let showComments = { post in
                router.presentedSheet = .comments(
                    post: post,
                    isBackgroundWhite: post.contentType == .text ? true : false,
                    transitions: .init(openProfile: { userID in
                        router .navigate(to: .accountDetail(id: userID))
                    })
                )
            }
            
            VStack(alignment: .center, spacing: 0) {
                FeedTabControllerView(feedPage: $feedPage)

                TabView(selection: $feedPage) {
                    let regularVM = NormalFeedViewModel(
                        feedType: .regular,
                        apiService: apiManager.apiService,
                        filters: .shared,
                        transitions: .init(openProfile: openProfile, showComments: showComments)
                    )
                    NormalFeedView(viewModel: regularVM)
                        .tag(FeedPage.normalFeed)

                    let videoVM = VideoFeedViewModel(
                        apiService: apiManager.apiService,
                        filters: .shared,
                        transitions: .init(openProfile: openProfile, showComments: showComments)
                    )
                    ReelsMainView(viewModel: videoVM)
                        .tag(FeedPage.videoFeed)
                        .onAppear {
                            audioManager.isInRestrictedView = true
                        }
                        .onDisappear {
                            audioManager.isInRestrictedView = false
                        }

                    let audioVM = NormalFeedViewModel(
                        feedType: .audio,
                        apiService: apiManager.apiService,
                        filters: .shared,
                        transitions: .init(openProfile: openProfile, showComments: showComments)
                    )
                    NormalFeedView(viewModel: audioVM)
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
        @EnvironmentObject private var apiManager: APIServiceManager
        @StateObject private var viewModel: NormalFeedViewModel

        init(viewModel: NormalFeedViewModel) {
            self._viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    ScrollToView()
                    LazyVStack(spacing: 20) {
                        PostsListView(fetcher: viewModel, navigator: viewModel.transitions)
                    }
                    .padding(.bottom, 10)
                }
                .refreshable {
                    HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                    viewModel.fetchPosts(reset: true)
                }
                .onChange(of: selectedTabScrollToTop) {
                    if selectedTabScrollToTop == 0, router.path.isEmpty {
                        withAnimation {
                            proxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.onAppear()
                viewModel.fetchPosts(reset: true)
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
