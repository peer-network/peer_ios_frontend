//
//  WalletTab.swift
//  PeerApp
//
//  Created by Артем Васин on 22.01.25.
//

import SwiftUI
import DesignSystem
import Environment
import Wallet

struct WalletTab: View {
    @EnvironmentObject private var theme: Theme
    
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            WalletView()
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
        }
        .withSafariRouter()
        .environmentObject(router)
    }
}

#Preview {
    ProfileTab()
}
