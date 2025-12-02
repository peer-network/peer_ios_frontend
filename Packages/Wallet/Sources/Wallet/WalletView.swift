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
    @State private var isHeaderAtTop = false

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Wallet")
        } content: {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 20) {
                        GemsMainView()
                            .id(0)
                        WithdrawalView()

                        TransactionsListView(viewModel: viewModel, isHeaderAtTop: $isHeaderAtTop, scrollProxy: scrollProxy)
                            .id(1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                .refreshable {
                    HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                    viewModel.fetchContent()
                    viewModel.fetchTransactionHistory(reset: true)
                }
            }
        }
        .environmentObject(viewModel)
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.fetchContent()
            viewModel.fetchTransactionHistory(reset: true)
        }
        .trackScreen(AppScreen.wallet)
    }
}
