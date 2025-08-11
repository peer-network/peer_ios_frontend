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

    deinit {
        timer?.invalidate()
    }
}
