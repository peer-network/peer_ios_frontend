//
//  SystemPopupManaging.swift
//  Environment
//
//  Created by Artem Vasin on 03.11.25.
//

import SwiftUI

public enum SystemPopupType {
    case error(text: String)
    
    case postPromotion
    case postPromotionHidden
    case postPromotionReview
    case postPromotionStarted(endDate: String)
    
    case logout
    case deactivateAccount
    case reportUser
    case reportPost
    case reportComment

    case transferSuccess

    case shopPurchaseSuccess
    case shopPurchaseFailed(error: String)
}

/// Protocol defining the interface for system popup management
@MainActor
public protocol SystemPopupManaging: ObservableObject {
    static var shared: Self { get }

    var presentedPopupBuilder: (() -> AnyView)? { get set }

    func presentPopup(
        _ type: SystemPopupType,
        confirmation: @escaping () -> Void,
        cancel: (() -> Void)?
    )

    func dismiss()
}

public extension SystemPopupManaging {
    func presentPopup(
        _ type: SystemPopupType,
        confirmation: @escaping () -> Void
    ) {
        presentPopup(type, confirmation: confirmation, cancel: nil)
    }
}
