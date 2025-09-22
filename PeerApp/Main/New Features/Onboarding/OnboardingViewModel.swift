//
//  OnboardingViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 04.09.25.
//

import SwiftUI
import DesignSystem
import Environment

enum OnboardingStep: Int, CaseIterable, Hashable, Identifiable {
    case welcome
    case prices
    case earnings
    case distribution
    case spending

    var id: Self { self }

    func bottomHintText(dailyTokensAmount: Int) -> String? {
        switch self {
            case .welcome:
                "Every interaction earns you Gems, your path to Peer Tokens."
            case .prices:
                "But hey - you can also invite friends and **_earn 1%_** of their token income daily."
            case .earnings:
                "The more Gems you collect, the bigger your share of the \(dailyTokensAmount.formatted(.number)) daily minted Peer Tokens. Simple."
            case .distribution, .spending:
                nil
        }
    }

    var next: OnboardingStep? {
        guard let idx = Self.allCases.firstIndex(of: self),
              idx < Self.allCases.count - 1 else { return nil }
        return Self.allCases[idx + 1]
    }

    var previous: OnboardingStep? {
        guard let idx = Self.allCases.firstIndex(of: self),
              idx > 0 else { return nil }
        return Self.allCases[idx - 1]
    }

    static var first: OnboardingStep { Self.allCases.first! }
    static var last: OnboardingStep { Self.allCases.last! }
}

enum OnboardingCloseButtonType {
    case skip
    case close

    var buttonConfig: StateButtonConfig {
        switch self {
            case .skip:
                    .init(buttonSize: .small, buttonType: .teritary, title: "Skip")
            case .close:
                    .init(buttonSize: .small, buttonType: .teritary, title: "Close"/*, icon: Icons.x, iconPlacement: .leading*/)
        }
    }
}

final class OnboardingViewModel: ObservableObject {
    let dismissAction: (_ isSkipped: Bool) -> Void

    let closeButtonType: OnboardingCloseButtonType

    @Published var onboardingStep: OnboardingStep = .welcome

    let tokenomics: ConstantsConfig.Tokenomics
    let dailyFree: ConstantsConfig.DailyFreeData
    let minting: ConstantsConfig.MintingData

    var isFirst: Bool { onboardingStep == .first }
    var isLast: Bool { onboardingStep == .last }

    init(closeButtonType: OnboardingCloseButtonType, tokenomics: ConstantsConfig.Tokenomics, dailyFree: ConstantsConfig.DailyFreeData, minting: ConstantsConfig.MintingData, dismissAction: @escaping (_ isSkipped: Bool) -> Void) {
        self.closeButtonType = closeButtonType
        self.tokenomics = tokenomics
        self.dailyFree = dailyFree
        self.minting = minting
        self.dismissAction = dismissAction
    }

    func goNext() {
        if let next = onboardingStep.next {
            onboardingStep = next
        }
    }

    func goBack() {
        if let prev = onboardingStep.previous {
            onboardingStep = prev
        }
    }
}
