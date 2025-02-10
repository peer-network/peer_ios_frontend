//
//  FeedNewTab.swift
//  PeerApp
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Environment
import DesignSystem
import SFSafeSymbols
import FeedNew

struct FeedNewTab: View {
    @EnvironmentObject private var theme: Theme
    
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FeedView()
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
        }
        .withSafariRouter()
        .environmentObject(router)
    }
}
