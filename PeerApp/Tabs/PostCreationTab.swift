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

    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            PostCreationView()
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
                .onChange(of: selectedTabEmptyPath) {
                    if selectedTabEmptyPath == 2, !router.path.isEmpty {
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
