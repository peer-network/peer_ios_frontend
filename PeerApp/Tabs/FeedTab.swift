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

    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FeedView()
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
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
