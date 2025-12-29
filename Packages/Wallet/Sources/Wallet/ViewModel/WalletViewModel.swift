//
//  WalletViewModel.swift
//  Wallet
//
//  Created by Артем Васин on 22.01.25.
//

import SwiftUI
import Models
import Environment

@MainActor
final class WalletViewModel: ObservableObject {
    @Published public private(set) var balanceState: ContentState<WalletBalance> = .loading(placeholder: .placeholder)
    public private(set) var balance: WalletBalance?

    public unowned var apiService: APIService!

    @frozen
    public enum TransactionHistoryState {
        case loading
        case display
        case error(Error)
    }

    @Published private(set) var transactionHistoryState = TransactionHistoryState.loading
    private var currentTransactionHistoryOffset: Int = 0
    private(set) var hasMoreTransactions: Bool = true

    @Published private(set) var transactions: [Models.Transaction] = []
    private var transactionHistoryFetchTask: Task<Void, Never>?

    init() {}

    func fetchContent() {
        Task { [weak self] in
            guard let self else { return }

            let result = await apiService.fetchLiquidityState()

            try Task.checkCancellation()

            switch result {
                case .success(let amount):
                    let walletBalance = WalletBalance(amount: amount)
                    if balance?.amount != walletBalance.amount {
                        fetchTransactionHistory(reset: true)
                    }
                    balance = walletBalance
                    balanceState = .display(content: walletBalance)
                case .failure(let apiError):
                    balanceState = .error(error: apiError)
            }
        }
    }

    func fetchTransactionHistory(reset: Bool) {
        if let existingTask = transactionHistoryFetchTask, !existingTask.isCancelled {
            return
        }

        if reset {
            transactions.removeAll()
            currentTransactionHistoryOffset = 0
            hasMoreTransactions = true
        }

        if transactions.isEmpty {
            transactionHistoryState = .loading
        }

        transactionHistoryFetchTask = Task {
            do {
                let result = await apiService.fetchTransactionsHistory(after: currentTransactionHistoryOffset)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedTransactions):
                        await MainActor.run {
                            transactions.append(contentsOf: fetchedTransactions)

                            if fetchedTransactions.count != 20 {
                                hasMoreTransactions = false
                            } else {
                                currentTransactionHistoryOffset += 20
                            }
                            transactionHistoryState = .display
                        }
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {

            } catch {
                await MainActor.run {
                    transactionHistoryState = .error(error)
                }
            }

            transactionHistoryFetchTask = nil
        }
    }
}
