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

public struct FeedView: View {
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
        .trackScreen(AppScreen.feed)
    }

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
                        .rotationEffect(.degrees(showFilters ? 180 : 0))
                        .animation(.default, value: showFilters)
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

extension CGRect: @retroactive @unchecked Sendable { }
