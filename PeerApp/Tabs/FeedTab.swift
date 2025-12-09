//
//  FeedTab.swift
//  PeerApp
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Environment
import FeedNew

struct FeedTab: View {
    @Environment(\.selectedTabEmptyPath) private var selectedTabEmptyPath

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FeedView()
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                .withSheetDestinations(sheetDestinations: $router.presentedSheet, apiServiceManager: apiManager)
                .onChange(of: selectedTabEmptyPath) {
                    if selectedTabEmptyPath == 0, !router.path.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            router.emptyPath()
                        }
                    }
                }
        }
        .withSafariRouter()
        .environmentObject(router)
    }
}
