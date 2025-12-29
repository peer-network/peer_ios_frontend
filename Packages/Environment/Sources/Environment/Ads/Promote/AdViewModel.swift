//
//  AdViewModel.swift
//  Environment
//
//  Created by Artem Vasin on 03.11.25.
//

import Combine
import Models
import Foundation

@MainActor
public final class AdViewModel: ObservableObject {
    public unowned var apiService: APIService!
    public unowned var popupService: (any SystemPopupManaging)!

    public let post: Post
    public let tokenomics: ConstantsConfig.Tokenomics
    public private(set) var balance: Decimal = 0

    public let onGoToProfile: () -> Void
    public let onGoToPost: () -> Void

    public var hasEnoughTokens: Bool {
        balance > Decimal(tokenomics.actionTokenPrices.advertisementPinned)
    }

    public var adPrice: Double {
        tokenomics.actionTokenPrices.advertisementPinned
    }

    public var peerFee: (percent: Int, amount: Int) {
        let percent: Int = Int(tokenomics.fees.peer * 100)
        let amount: Int = Int(adPrice * tokenomics.fees.peer)
        return (percent: percent, amount: amount)
    }

    public var inviterFee: (percent: Int, amount: Int) {
        let percent: Int = Int(tokenomics.fees.invitation * 100)
        let amount: Int = Int(adPrice * tokenomics.fees.invitation)
        return (percent: percent, amount: amount)
    }

    public var burnFee: (percent: Int, amount: Int) {
        let percent: Int = Int(tokenomics.fees.burn * 100)
        let amount: Int = Int(adPrice * tokenomics.fees.burn)
        return (percent: percent, amount: amount)
    }

    public init(post: Post, tokenomics: ConstantsConfig.Tokenomics, onGoToProfile: @escaping () -> Void, onGoToPost: @escaping () -> Void) {
        self.post = post
        self.tokenomics = tokenomics
        self.onGoToProfile = onGoToProfile
        self.onGoToPost = onGoToPost

        fetchUserBalance()
    }

    public func fetchUserBalance() {
        Task { [weak self] in
            guard let self else { return }

            let result = await apiService.fetchLiquidityState()

            try Task.checkCancellation()

            switch result {
                case .success(let amount):
                    balance = amount
                case .failure(let apiError):
                    return
            }
        }
    }

    public func startPromotion() async {
        let result = await apiService.promotePostPinned(for: post.id)

        switch result {
            case .success(let date):
                popupService.presentPopup(.postPromotionStarted(endDate: convertUTCToLocalDate(date) ?? "")) {
                    self.onGoToPost()
                } cancel: {
                    self.onGoToProfile()
                }
            case .failure(let apiError):
                popupService.presentPopup(.error(text: apiError.userFriendlyMessage)) {
                    Task {
                        await self.startPromotion()
                    }
                }
        }
    }

    func convertUTCToLocalDate(_ utcDateString: String) -> String? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        guard let date = dateFormatter.date(from: utcDateString) else {
            return nil
        }

        dateFormatter.dateFormat = "MMM d, yyyy 'at' HH:mm"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: date)
    }
}
