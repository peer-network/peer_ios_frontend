//
//  ProfileTab.swift
//  PeerApp
//
//  Created by Артем Васин on 23.12.24.
//

import SwiftUI
import Environment
import ProfileNew

struct ProfileTab: View {
    @Environment(\.selectedTabEmptyPath) private var selectedTabEmptyPath

    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if let userId = accountManager.userId {
                    ProfilePageView(userId: userId)
                        .toolbar(.hidden, for: .navigationBar)
                        .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                        .withShopRouter(router: router)
                        .withSheetDestinations(sheetDestinations: $router.presentedSheet, apiServiceManager: apiManager)
                        .id(userId)
                } else {
                    ProfilePageView(userId: "")
                        .toolbar(.hidden, for: .navigationBar)
                        .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                        .withShopRouter(router: router)
                        .withSheetDestinations(sheetDestinations: $router.presentedSheet, apiServiceManager: apiManager)
                        .redacted(reason: .placeholder)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: selectedTabEmptyPath) {
                if selectedTabEmptyPath == 4, !router.path.isEmpty {
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

#Preview {
    ProfileTab()
}
