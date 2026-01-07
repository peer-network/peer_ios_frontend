//
//  FeedView.swift
//  FeedNew
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import Environment
import DesignSystem
import Analytics
import AVFAudio

public struct FeedView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var audioManager: AudioSessionManager

    @State private var feedPage: FeedPage = .normalFeed

    // Filters view properties
    @State private var showFilters = false
    @State private var filtersPosition: CGRect = .zero

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            headerView
        } content: {
            //            if #available(iOS 18, *) {
            //                newContentView
            //            } else {
            oldContentView
            //            }
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
        .trackScreen(AppScreen.feed)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            if let url = activity.webpageURL {
                router.handle(url: url)
            }
        }
        .onOpenURL { url in
            router.handle(url: url)
        }
    }

    @available(iOS 18.0, *)
    public var newContentView: some View {
        HeaderPageScrollView {
            EmptyView()
        } labels: {
            PageLabel(title: "Regular", icon: Icons.smile)
            PageLabel(title: "Video", icon: Icons.playRectangle)
            PageLabel(title: "Audio", icon: Icons.musicNote)
        } pages: {
            RegularFeedView()
                .trackScreen(AppScreen.photoAndTextFeed)

            Text("123")

            //            ReelsFeedView()
            //                .ignoresSafeArea(.container, edges: .all)
            //                .onAppear {
            //                    audioManager.isInRestrictedView = true
            //                }
            //                .onDisappear {
            //                    audioManager.isInRestrictedView = false
            //                }
            //                .trackScreen(AppScreen.videoFeed)

            AudioFeedView()
                .trackScreen(AppScreen.audioFeed)
        } onRefresh: {
            //
        }
    }

    public var oldContentView: some View {
        VStack(alignment: .center, spacing: 0) {
            FeedTabControllerView(feedPage: $feedPage)

            TabView(selection: $feedPage) {
                RegularFeedView()
                    .tag(FeedPage.normalFeed)
                    .trackScreen(AppScreen.photoAndTextFeed)

                ReelsFeedView()
                    .ignoresSafeArea(.container, edges: .all)
                    .tag(FeedPage.videoFeed)
                    .onAppear {
                        audioManager.isInRestrictedView = true
                    }
                    .onDisappear {
                        audioManager.isInRestrictedView = false
                    }
                    .trackScreen(AppScreen.videoFeed)
                    .onAppear {
                        let session = AVAudioSession.sharedInstance()
                        try? session.setCategory(.playback, mode: .moviePlayback, options: [.duckOthers])
                        try? session.setActive(true)
                    }
                    .onDisappear {
                        let session = AVAudioSession.sharedInstance()
                        try? session.setActive(false, options: [.notifyOthersOnDeactivation])
                    }

                AudioFeedView()
                    .tag(FeedPage.audioFeed)
                    .trackScreen(AppScreen.audioFeed)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    private var headerView: some View {
        Button {
            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                showFilters.toggle()
            }
        } label: {
            Icons.magnifyingglass
                .iconSize(height: 19.25)
                .frame(width: 21, height: 21)
                .contentShape(.rect)
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .global)
                } action: { newValue in
                    filtersPosition = newValue
                }
        }
    }
}

extension CGRect: @retroactive @unchecked Sendable { }
