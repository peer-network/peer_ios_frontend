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
    @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop

    @EnvironmentObject private var router: Router
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
                    ScrollToView()
                    VStack(spacing: 20) {
                        GemsMainView()
                            .id(0)

                        transferButton

                        TransactionsListView(viewModel: viewModel, isHeaderAtTop: $isHeaderAtTop, scrollProxy: scrollProxy)
                            .id(1)
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
                .refreshable {
                    HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                    viewModel.fetchContent()
                    viewModel.fetchTransactionHistory(reset: true)
                }
                .onChange(of: selectedTabScrollToTop) {
                    if selectedTabScrollToTop == 2, router.path.isEmpty {
                        withAnimation {
                            scrollProxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                        }
                    }
                }
            }
        }
        .environmentObject(viewModel)
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            viewModel.fetchContent()
            viewModel.fetchTransactionHistory(reset: true)
        }
//        .trackScreen(AppScreen.wallet)
    }

    private var transferButton: some View {
        Button {
            if let balance = viewModel.balance?.amount {
                router.navigate(to: RouterDestination.transferV2(balance: balance))
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Circle()
                    .frame(height: 40)
                    .overlay {
                        Icons.arrowDownNormal
                            .iconSize(height: 14.5)
                            .foregroundStyle(Colors.whitePrimary)
                            .rotationEffect(.degrees(225))
                    }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Transfer")
                        .appFont(.bodyRegular)

                    Spacer()
                        .frame(minHeight: 0)
                        .frame(maxHeight: .infinity)
                        .layoutPriority(-1)

                    Text("To user")
                        .appFont(.smallLabelRegular)
                        .foregroundStyle(Colors.textSuggestions)
                }
                .frame(height: 40)

                Spacer()
                    .frame(minWidth: 0)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                Icons.arrowNormal
                    .iconSize(height: 15)
            }
            .foregroundStyle(Colors.blackDark)
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(Colors.whitePrimary)
            }
            .contentShape(.rect)
        }

    }
}
