//
//  AppScreen.swift
//  Analytics
//
//  Created by Artem Vasin on 22.04.25.
//

public enum AppScreen: ScreenTrackable {
    case auth

    case feed
    case photoAndTextFeed
    case videoFeed
    case audioFeed
    case versionHistory
    case search
    case postCreation
    case wallet
    case profile // TODO: Separate into ownProfile and otherProfile ?
    case settings
    case referrals

    case commentsSheet
    case followersSheet
    case followingSheet
    case friendsSheet

    public var screenName: String {
        switch self {
            case .auth:
                return "Auth"
            case .feed:
                return "Feed"
            case .photoAndTextFeed:
                return "PhotoAndTextFeed"
            case .videoFeed:
                return "VideoFeed"
            case .audioFeed:
                return "AudioFeed"
            case .versionHistory:
                return "VersionHistory"
            case .search:
                return "Search"
            case .postCreation:
                return "PostCreation"
            case .wallet:
                return "Wallet"
            case .profile:
                return "Profile"
            case .settings:
                return "Settings"
            case .referrals:
                return "Referrals"
            case .commentsSheet:
                return "CommentsSheet"
            case .followersSheet:
                return "FollowersSheet"
            case .followingSheet:
                return "FollowingSheet"
            case .friendsSheet:
                return "FriendsSheet"
        }
    }

    public var screenClass: String {
        switch self {
            case .auth:
                return "MainAuthView"
            case .feed:
                return "FeedView"
            case .photoAndTextFeed:
                return "FeedView"
            case .videoFeed:
                return "FeedView"
            case .audioFeed:
                return "FeedView"
            case .versionHistory:
                return "VersionHistoryView"
            case .search:
                return "SearchView"
            case .postCreation:
                return "PostCreationView"
            case .wallet:
                return "WalletView"
            case .profile:
                return "ProfileView"
            case .settings:
                return "SettingsView"
            case .referrals:
                return "ReferralsView"
            case .commentsSheet:
                return "CommentsView"
            case .followersSheet:
                return "ProfilesSheetView"
            case .followingSheet:
                return "ProfilesSheetView"
            case .friendsSheet:
                return "ProfilesSheetView"
        }
    }
}
