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
    
    @Binding var selectedTab: AppTab
    @ObservedObject var appRouter: Router
    
    @State private var selectedTabScrollToTop: Int = -1
    
    @StateObject private var tabManager = AppTabManager.shared
    
    var body: some View {
        tabBarView
    }
    
    @ViewBuilder
    private var tabBarView: some View {
        TabView(
          selection: .init(
            get: {
              selectedTab
            },
            set: { newTab in
              updateTab(with: newTab)
            })
        ) {
            ForEach(tabManager.tabs) { tab in
                tab.makeContentView(selectedTab: $selectedTab)
                    .tabItem {
                        if userPreferences.showTabLabel {
                            tab.label
                                .environment(\.symbolVariants, tab == selectedTab ? .fill : .none)
                        } else {
                            Image(systemSymbol: tab.iconSymbol)
                        }
                    }
                    .tag(tab)
                    .badge(badgeFor(tab: tab))
                    .toolbarBackground(theme.primaryBackgroundColor.opacity(0.30), for: .tabBar)
            }
        }
        .withSheetDestinations(sheetDestinations: $appRouter.presentedSheet)
        .environment(\.selectedTabScrollToTop, selectedTabScrollToTop)
    }
    
    private func updateTab(with newTab: AppTab) {
        if newTab == .newPost {
            appRouter.presentedSheet = .postEditor
            return
        }
        
        HapticManager.shared.fireHaptic(.tabSelection)
        
        if selectedTab == newTab {
            selectedTabScrollToTop = newTab.rawValue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTabScrollToTop = -1
            }
        } else {
            selectedTabScrollToTop = -1
        }
        
        selectedTab = newTab
    }
    
    private func badgeFor(tab: AppTab) -> Int {
        // TODO: Implement
        return 0
    }
}
