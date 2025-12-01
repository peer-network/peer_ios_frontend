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
final class WalletViewModel: SimpleContentFetcher, ObservableObject {
    @Published public private(set) var state: ContentState<WalletBalance> = .loading(placeholder: .placeholder)
    public private(set) var balance: WalletBalance?

    public unowned var apiService: APIService!
    
    @Published var countdown: String = "00:00:00"

    private var timer: Timer?

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

    init() {
        startTimer()
    }

    func fetchContent() {
        Task { [weak self] in
            guard let self else { return }

            let result = await apiService.fetchLiquidityState()

            try Task.checkCancellation()

            switch result {
                case .success(let amount):
                    let walletBalance = WalletBalance(amount: amount, tokenPrice: 0.1)
                    balance = walletBalance
                    state = .display(content: walletBalance)
                case .failure(let apiError):
                    state = .error(error: apiError)
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task {
                await self?.updateCountdown()
            }
        }
    }

    private func updateCountdown() async {
        let now = Foundation.Date()
        let calendar = Calendar(identifier: .gregorian)
        guard let cetTimeZone = TimeZone(identifier: "CET") else { return }

        // Convert current time to CET
        let cetNow = now.convertToTimeZone(cetTimeZone)

        // Find next reset at 00:00 CET
        let nextReset = calendar.nextDate(
            after: cetNow,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? cetNow

        let timeLeft = Int(nextReset.timeIntervalSince(cetNow))
        if timeLeft <= 0 {
            //                await fetchWalletData() // Fetch when countdown hits zero
            // also fetch daily free here
        }

        let hours = (timeLeft / 3600) % 24
        let minutes = (timeLeft / 60) % 60
        let seconds = timeLeft % 60
        countdown = String(format: "%02d : %02d : %02d", hours, minutes, seconds)
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
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                await MainActor.run {
                    transactionHistoryState = .error(error)
                }
            }

            transactionHistoryFetchTask = nil
        }
    }

    deinit {
        timer?.invalidate()
    }
}
