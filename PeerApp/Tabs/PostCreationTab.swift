//
//  PostCreationTab.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.03.25.
//

import SwiftUI
import Environment
import PostCreation

struct PostCreationTab: View {
    @Environment(\.selectedTabEmptyPath) private var selectedTabEmptyPath

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
//            PostCreationView()
            PostCreationMainView()
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                .withShopRouter(router: router)
                .withSheetDestinations(sheetDestinations: $router.presentedSheet, apiServiceManager: apiManager)
                .onChange(of: selectedTabEmptyPath) {
                    if selectedTabEmptyPath == 1, !router.path.isEmpty {
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
