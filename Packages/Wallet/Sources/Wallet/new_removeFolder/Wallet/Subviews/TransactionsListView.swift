//
//  TransactionsListView.swift
//  Wallet
//
//  Created by Artem Vasin on 24.11.25.
//

import SwiftUI
import DesignSystem
import Models

struct TransactionsListView: View {
    @ObservedObject var viewModel: WalletViewModel
    @Binding var isHeaderAtTop: Bool
    let scrollProxy: ScrollViewProxy

    var body: some View {
        LazyVStack(spacing: 10, pinnedViews: .sectionHeaders) {
            Section {
                transactionsList
            } header: {
                transactionHistoryHeaderView
                    .background(Colors.blackDark)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { newValue in
                                    if newValue < 107 {
                                        isHeaderAtTop = true
                                    } else {
                                        isHeaderAtTop = false
                                    }
                                }
                        }
                    )
            }
        }
    }

    private var transactionHistoryHeaderView: some View {
        Button {
            if isHeaderAtTop {
                withAnimation {
                    scrollProxy.scrollTo(0, anchor: .top)
                }
            } else {
                withAnimation {
                    scrollProxy.scrollTo(1, anchor: .top)
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text("Transactions")
                    .appFont(.bodyBold)

                Spacer()
                    .frame(minWidth: 0)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                Icons.arrowDown
                    .iconSize(height: 8)
                    .rotationEffect(.degrees(isHeaderAtTop ? 180 : 0))
                    .animation(.easeInOut, value: isHeaderAtTop)
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 10)
            .contentShape(.rect)
        }
    }

    @ViewBuilder
    private var transactionsList: some View {
        switch viewModel.transactionHistoryState {
            case .loading:
                ForEach(Models.Transaction.placeholders(count: 15), id: \.id) { transaction in
                    TransactionView(transaction: transaction)
                        .contentShape(.rect)
                        .allowsHitTesting(false)
                        .skeleton(isRedacted: true)
                }
            case .display:
                if viewModel.transactions.isEmpty {
                    noTransactionsView
                } else {
                    ForEach(viewModel.transactions, id: \.id) { transaction in
                        TransactionView(transaction: transaction)
                    }

                    if viewModel.hasMoreTransactions {
                        NextPageView {
                            viewModel.fetchTransactionHistory(reset: false)
                        }
                    } else {
                        EmptyView()
                    }
                }
            case .error(let error):
                ErrorView(title: "Error", description: error.userFriendlyDescription) {
                    viewModel.fetchTransactionHistory(reset: true)
                }
                .padding(20)
        }
    }

    private var noTransactionsView: some View {
        VStack(alignment: .center, spacing: 13) {
            Text("No transactions yet. Create a post to start earning!")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whiteSecondary)
                .multilineTextAlignment(.center)

            let buttonConfig = StateButtonConfig(buttonSize: .small, buttonType: .secondary, title: "Create new post")
            StateButton(config: buttonConfig) {
                // TODO: Add action to switch tab
            }
            .fixedSize()
        }
    }
}
