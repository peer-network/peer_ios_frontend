//
//  SystemPopupType.swift
//  DesignSystem
//
//  Created by Artem Vasin on 28.10.25.
//

import SwiftUI

public enum SystemPopupType {
    case postPromotion
    case logout
    case deactivateAccount
    case reportUser
    case reportPost
    case reportComment

    public var icon: Image {
        switch self {
            case .postPromotion:
                return IconsNew.megaphone
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
        }
    }

    public var iconColor: Color {
        switch self {
            case .postPromotion:
                return Colors.whitePrimary
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
        }
    }

    public var iconBackgroundColor: Color {
        switch self {
            case .postPromotion:
                return Colors.version
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
        }
    }

    public var title: String {
        switch self {
            case .postPromotion:
                return "Ready to shine?"
            case .logout:
                return "Are you sure you want to log out?"
            case .deactivateAccount:
                return "Are you sure you want to deactivate your profile?"
            case .reportUser:
                return "Are you sure you want to report this user?"
            case .reportPost:
                return "Are you sure you want to report this post?"
            case .reportComment:
                return "Are you sure you want to report this comment?"
        }
    }

    public var titleColor: Color {
        switch self {
            case .postPromotion:
                return Colors.whitePrimary
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
        }
    }

    public var description: String? {
        switch self {
            case .postPromotion:
                return "Your post will go to the top of the feed. Once confirmed, it can’t be cancelled."
            case .logout:
                return nil
            case .deactivateAccount:
                return "Your data will still be storaged for 6 months."
            case .reportUser:
                return nil
            case .reportPost:
                return nil
            case .reportComment:
                return nil
        }
    }

    public var confirmationButtonConfig: StateButtonConfig {
        switch self {
            case .postPromotion:
                return .init(buttonSize: .small, buttonType: .primary, title: "Promote")
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
        }
    }
}
