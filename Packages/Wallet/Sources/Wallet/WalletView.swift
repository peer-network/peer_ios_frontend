//
//  WalletView.swift
//  Wallet
//
//  Created by Артем Васин on 22.01.25.
//

import SwiftUI
import DesignSystem
import Environment
import Analytics

public struct WalletView: View {
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel = WalletViewModel()
    
    public init() {
    }
    
    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Wallet")
        } content: {
            ScrollView {
                VStack(spacing: 20) {
                    GemsMainView()
                    WithdrawalView()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable {
                HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                viewModel.fetchContent()
            }
        }
        .background(Colors.textActive)
        .environmentObject(viewModel)
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.fetchContent()
        }
        .trackScreen(AppScreen.wallet)
    }
}

#Preview {
    WalletView()
        .environmentObject(APIServiceManager(.mock))
//        .analyticsService(MockAnalyticsService())
}
