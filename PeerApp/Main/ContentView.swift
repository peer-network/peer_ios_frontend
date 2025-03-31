//
//  ContentView.swift
//  PeerApp
//
//  Created by Артем Васин on 13.12.24.
//

import SwiftUI
import Environment
import DesignSystem

struct ContentView: View {
    @EnvironmentObject private var userPreferences: UserPreferences
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var audioManager: AudioSessionManager

    @Binding var selectedTab: AppTab
    @ObservedObject var appRouter: Router

    @State private var selectedTabScrollToTop: Int = -1
    @State private var selectedTabEmptyPath: Int = -1

    @StateObject private var tabManager = AppTabManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    ForEach(tabManager.tabs, id: \.self) { tab in
                        tab.makeContentView()
                            .apply {
                                if #available(iOS 18.0, *) {
                                    $0.toolbarVisibility(.hidden, for: .tabBar)
                                } else {
                                    $0.toolbar(.hidden, for: .tabBar)
                                }
                            }
                    }
                }

                if audioManager.currentPlayerObject != nil, !audioManager.isInRestrictedView {
                    FloatingAudioPanelView()
                        .padding(.horizontal, 10)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .bottom).animation(.linear))
                        .animation(.linear, value: audioManager.isInRestrictedView)
                }
            }
            
            tabBarView
        }
        .withSheetDestinations(sheetDestinations: $appRouter.presentedSheet)
        .environment(\.selectedTabScrollToTop, selectedTabScrollToTop)
        .environment(\.selectedTabEmptyPath, selectedTabEmptyPath)
        .ignoresSafeArea(.keyboard)
    }

    private var tabBarView: some View {
        HStack(spacing: 0) {
            ForEach(tabManager.tabs, id: \.self) { tab in
                Button {
                    withAnimation {
                        updateTab(with: tab)
                    }
                } label: {
                    Group {
                        if tab == selectedTab {
                            tab.iconFilled
                                .iconSize(height: 22)
                        } else {
                            tab.icon
                                .iconSize(height: 22)
                        }
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                }
            }
        }
        .background(Color.backgroundDark)
    }

    private func updateTab(with newTab: AppTab) {
        HapticManager.shared.fireHaptic(.tabSelection)
        
        if selectedTab == newTab {
            selectedTabScrollToTop = newTab.rawValue
            selectedTabEmptyPath = newTab.rawValue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTabScrollToTop = -1
                selectedTabEmptyPath = -1
            }
        } else {
            selectedTabScrollToTop = -1
            selectedTabEmptyPath = -1
        }
        
        selectedTab = newTab
    }
}
