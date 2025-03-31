//
//  WalletView.swift
//  Wallet
//
//  Created by Артем Васин on 22.01.25.
//

import SwiftUI
import DesignSystem
import Environment

public struct WalletView: View {
    @EnvironmentObject private var accountManager: AccountManager

    @StateObject private var viewModel = WalletViewModel()
    
    public init() {
    }
    
    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Wallet")
        } content: {
            ScrollView {
                GemsMainView()
            }
            .refreshable {
                HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                await viewModel.fetchCurrentLiquidity()
            }
        }
        .background(Color.backgroundDark)
        .environmentObject(viewModel)
    }
}

#Preview {
    WalletView()
}
