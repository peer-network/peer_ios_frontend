//
//  FeedTab.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Environment
import DesignSystem
import SFSafeSymbols
//import Feed

struct FeedTab: View {
    @EnvironmentObject private var theme: Theme
    
    @StateObject private var router = Router()
    
//    @StateObject private var feedContentSorting = FeedContentSorting.shared
    
    var body: some View {
        NavigationStack(path: $router.path) {
//            FeedView(type: .home)
            EmptyView()
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
//                .toolbar {
//                    toolbarView
//                }
                .toolbarBackground(theme.primaryBackgroundColor.opacity(0.30), for: .navigationBar)
        }
        .withSafariRouter()
        .environmentObject(router)
    }
    
//    @ToolbarContentBuilder
//    private var toolbarView: some ToolbarContent {
//        ToolbarTitleMenu {
//            feedFilterButton
//        }
//        
//        PostEditorToolbarItem()
//    }
//    
//    @ViewBuilder
//    private var feedFilterButton: some View {
//        contentSortingByTimeButton
//        contentSortingByPopularityButton
//        Divider()
//        contentFilterButton
//    }
//    
//    private var contentFilterButton: some View {
//        Button {
//            router.presentedSheet = .feedContentFilter
//        } label: {
//            Label("Content Filter", systemSymbol: .line3HorizontalDecrease)
//        }
//    }
//    
//    private var contentSortingByTimeButton: some View {
//        Picker("Sort by Time", selection: $feedContentSorting.sortByTime) {
//            ForEach(FeedContentSortingByTime.allCases, id: \.self) { sort in
//                Text(sort.rawValue)
//            }
//        }
//        .pickerStyle(.menu)
//    }
//    
//    private var contentSortingByPopularityButton: some View {
//        Picker("Sort by Popularity", selection: $feedContentSorting.sortByPopularity) {
//            ForEach(FeedContentSortingByPopularity.allCases, id: \.self) { sort in
//                Text(sort.rawValue)
//            }
//        }
//        .pickerStyle(.menu)
//    }
}
