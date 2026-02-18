//
//  SystemPopupType.swift
//  DesignSystem
//
//  Created by Artem Vasin on 28.10.25.
//

import SwiftUI
import Environment

public extension SystemPopupType {
    public var icon: Image {
        switch self {
            case .error:
                return IconsNew.exclamaitionMarkCircle
            case .postPromotion:
                return IconsNew.megaphone
            case .postPromotionHidden:
                return IconsNew.exclamaitionMarkCircle
            case .postPromotionReview:
                return IconsNew.exclamaitionMarkCircle
            case .postPromotionStarted:
                return IconsNew.checkCircle2
            case .logout:
                return IconsNew.exclamaitionMarkCircle
            case .deactivateAccount:
                return IconsNew.exclamaitionMarkCircle
            case .reportUser:
                return IconsNew.exclamaitionMarkCircle
            case .reportPost:
                return IconsNew.exclamaitionMarkCircle
            case .reportComment:
                return IconsNew.exclamaitionMarkCircle
            case .transferSuccess:
                return IconsNew.checkCircle2
            case .shopPurchaseSuccess:
                return IconsNew.shopSuccess
            case .shopPurchaseFailed:
                return IconsNew.shopFail
        }
    }

    public var iconColor: Color {
        switch self {
            case .error:
                return Colors.redAccent
            case .postPromotion:
                return Colors.whitePrimary
            case .postPromotionHidden:
                return Colors.redAccent
            case .postPromotionReview:
                return Colors.redAccent
            case .postPromotionStarted:
                return Colors.passwordBarsGreen
            case .logout:
                return Colors.redAccent
            case .deactivateAccount:
                return Colors.redAccent
            case .reportUser:
                return Colors.redAccent
            case .reportPost:
                return Colors.redAccent
            case .reportComment:
                return Colors.redAccent
            case .transferSuccess:
                return Colors.passwordBarsGreen
            case .shopPurchaseSuccess:
                return Color(red: 0.67, green: 1, blue: 0.4)
            case .shopPurchaseFailed:
                return Colors.redAccent
        }
    }

    public var iconBackgroundColor: Color {
        switch self {
            case .error:
                return Colors.redAccent.opacity(0.2)
            case .postPromotion:
                return Colors.version
            case .postPromotionHidden:
                return Colors.redAccent.opacity(0.2)
            case .postPromotionReview:
                return Colors.redAccent.opacity(0.2)
            case .postPromotionStarted:
                return Colors.passwordBarsGreen.opacity(0.2)
            case .logout:
                return Colors.redAccent.opacity(0.2)
            case .deactivateAccount:
                return Colors.redAccent.opacity(0.2)
            case .reportUser:
                return Colors.redAccent.opacity(0.2)
            case .reportPost:
                return Colors.redAccent.opacity(0.2)
            case .reportComment:
                return Colors.redAccent.opacity(0.2)
            case .transferSuccess:
                return Colors.passwordBarsGreen.opacity(0.2)
            case .shopPurchaseSuccess:
                return Color(red: 0.67, green: 1, blue: 0.4).opacity(0.2)
            case .shopPurchaseFailed:
                return Color(red: 1, green: 0.23, blue: 0.23).opacity(0.2)
        }
    }

    public var title: String {
        switch self {
            case .error:
                return "Something went wrong"
            case .postPromotion:
                return "Ready to shine?"
            case .postPromotionHidden:
                return "Your post is currently hidden"
            case .postPromotionReview:
                return "Your post is under review"
            case .postPromotionStarted:
                return "Your post promotion has started."
            case .logout:
                return "Are you sure you want to log out?"
            case .deactivateAccount:
                return "Are you sure you want to delete your profile, this can not be reverted?"
            case .reportUser:
                return "Are you sure you want to report this user?"
            case .reportPost:
                return "Are you sure you want to report this post?"
            case .reportComment:
                return "Are you sure you want to report this comment?"
            case .transferSuccess:
                return "Completed"
            case .shopPurchaseSuccess:
                return "Order Successfully Placed!"
            case .shopPurchaseFailed:
                return "Order Failed"
        }
    }

    public var titleColor: Color {
        switch self {
            case .error:
                return Colors.redAccent
            case .postPromotion:
                return Colors.whitePrimary
            case .postPromotionHidden:
                return Colors.redAccent
            case .postPromotionReview:
                return Colors.redAccent
            case .postPromotionStarted:
                return Colors.passwordBarsGreen
            case .logout:
                return Colors.redAccent
            case .deactivateAccount:
                return Colors.redAccent
            case .reportUser:
                return Colors.redAccent
            case .reportPost:
                return Colors.redAccent
            case .reportComment:
                return Colors.redAccent
            case .transferSuccess:
                return Colors.passwordBarsGreen
            case .shopPurchaseSuccess:
                return Color(red: 0.67, green: 1, blue: 0.4)
            case .shopPurchaseFailed:
                return Colors.redAccent
        }
    }

    public var description: String? {
        switch self {
            case .error(let text):
                return text
            case .postPromotion:
                return "Your post will go to the top of the feed. Once confirmed, it can’t be cancelled."
            case .postPromotionHidden:
                return "Your post has been reported and is temporarily hidden. Your promotion won’t be visible for all."
            case .postPromotionReview:
                return "Heads up: Your post was reported. When reviewed, its promotion might be hidden."
            case .postPromotionStarted(let date):
                return "Your post is now pinned and will expire on **\(date)** (24 hours from now)"
            case .logout:
                return nil
            case .deactivateAccount:
                return "Your personal will be removed from our system"
            case .reportUser:
                return nil
            case .reportPost:
                return nil
            case .reportComment:
                return nil
            case .transferSuccess:
                return "Your transfer was sent successfully."
            case .shopPurchaseSuccess:
                return "Your order has been confirmed. You’ll receive an email with delivery details within 1–3 days."
            case .shopPurchaseFailed(let errorText):
                return errorText
        }
    }

    public var firstButtonConfig: StateButtonConfig? {
        switch self {
            case .error:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .postPromotion:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .postPromotionHidden:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .postPromotionReview:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .postPromotionStarted:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Go to profile")
            case .logout:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .deactivateAccount:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .reportUser:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .reportPost:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .reportComment:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
            case .transferSuccess:
                return nil
            case .shopPurchaseSuccess:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Close")
            case .shopPurchaseFailed:
                return .init(buttonSize: .small, buttonType: .teritary, title: "Cancel")
        }
    }

    public var secondButtonConfig: StateButtonConfig? {
        switch self {
            case .error:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Try again")
            case .postPromotion:
                return .init(buttonSize: .small, buttonType: .primary, title: "Promote")
            case .postPromotionHidden:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Promote anyway")
            case .postPromotionReview:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Promote anyway")
            case .postPromotionStarted:
                return .init(buttonSize: .small, buttonType: .primary, title: "Go to post")
            case .logout:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Log out")
            case .deactivateAccount:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Delete account")
            case .reportUser:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Report")
            case .reportPost:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Report")
            case .reportComment:
                return .init(buttonSize: .small, buttonType: .secondary, title: "Report")
            case .transferSuccess:
                return .init(buttonSize: .small, buttonType: .primary, title: "Got it")
            case .shopPurchaseSuccess:
                return .init(buttonSize: .small, buttonType: .secondary, title: "To wallet")
            case .shopPurchaseFailed:
                return .init(buttonSize: .small, buttonType: .primary, title: "Try again")
        }
    }
}
