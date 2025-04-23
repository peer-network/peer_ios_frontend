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

    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            WalletView()
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
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
