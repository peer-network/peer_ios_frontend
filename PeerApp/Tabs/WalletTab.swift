//
//  WalletTab.swift
//  PeerApp
//
//  Created by Артем Васин on 22.01.25.
//

import SwiftUI
import Environment
import Wallet

struct WalletTab: View {
    @Environment(\.selectedTabEmptyPath) private var selectedTabEmptyPath

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            WalletView()
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                .withSheetDestinations(sheetDestinations: $router.presentedSheet, apiServiceManager: apiManager)
                .onChange(of: selectedTabEmptyPath) {
                    if selectedTabEmptyPath == 3, !router.path.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            router.emptyPath()
                        }
                    }
                }
                .onAppear {
//                    analytics.track(event: .tabSelected(.wallet))
                }
        }
        .withSafariRouter()
        .environmentObject(router)
    }
}
