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
                    if #available(iOS 18, *) {
                        ProfilePageView(userId: userId)
                            .toolbar(.hidden, for: .navigationBar)
                            .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                            .withSheetDestinations(sheetDestinations: $router.presentedSheet)
                            .id(userId)
                    } else {
                        ProfileView(userId: userId)
                            .toolbar(.hidden, for: .navigationBar)
                            .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                            .withSheetDestinations(sheetDestinations: $router.presentedSheet)
                            .id(userId)
                    }
                } else {
                    ProfileView(userId: "")
                        .toolbar(.hidden, for: .navigationBar)
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
