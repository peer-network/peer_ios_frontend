//
//  ProfileTab.swift
//  PeerApp
//
//  Created by Артем Васин on 23.12.24.
//

import SwiftUI
import Environment
import DesignSystem
import Profile

struct ProfileTab: View {
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var accountManager: AccountManager
    
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            if let userId = accountManager.userId {
                ProfileView(userId: userId, isCurrentUser: true)
                    .withAppRouter()
                    .withSheetDestinations(sheetDestinations: $router.presentedSheet)
                    .toolbarBackground(theme.primaryBackgroundColor.opacity(0.30), for: .navigationBar)
                    .id(userId)
            } else {
                ProfileView(user: .placeholder(), isCurrentUser: true)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
            }
            
        }
        .withSafariRouter()
        .environmentObject(router)
    }
}

#Preview {
    ProfileTab()
}
