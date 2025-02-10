//
//  Tabs.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import SFSafeSymbols

enum AppTab: Int, Identifiable, CaseIterable {
    case feed
    case notifications
    case explore
    case profile
    case chats
    case settings
    case newPost
    case reels
    case wallet
    
    var id: Int {
        rawValue
    }
    
    @ViewBuilder
    func makeContentView(selectedTab: Binding<AppTab>) -> some View {
        switch self {
            case .feed:
                FeedTab()
            case .notifications:
                Color.red
            case .explore:
                Color.red
            case .profile:
                ProfileTab()
            case .chats:
                Color.red
            case .settings:
                SettingsTab(isModal: false)
            case .newPost:
                VStack {}
            case .reels:
                Color.red
            case .wallet:
                FeedNewTab()
        }
    }
    
    @ViewBuilder
    var label: some View {
        Label(title, systemSymbol: iconSymbol)
    }
    
    var title: String {
        switch self {
            case .feed:
                "Feed"
            case .notifications:
                "Notifications"
            case .explore:
                "Explore"
            case .profile:
                "Profile"
            case .chats:
                "Chats"
            case .settings:
                "Settings"
            case .newPost:
                "New Post"
            case .reels:
                "Videos"
            case .wallet:
                "Wallet"
        }
    }
    
    var iconSymbol: SFSymbol {
        switch self {
            case .feed:
                    .rectangleStack
            case .notifications:
                    .bell
            case .explore:
                    .magnifyingglass
            case .profile:
                    .personCropCircle
            case .chats:
                    .bubbleLeft
            case .settings:
                    .gearshape
            case .newPost:
                    .squareAndPencil
            case .reels:
                    .playRectangle
            case .wallet:
                    .bitcoinsignCircle
        }
    }
}

final class AppTabManager: ObservableObject {
    enum TabEntries: String {
        case first, second, third, fourth, fifth
    }
    
    class Storage {
        @AppStorage(TabEntries.first.rawValue) var firstTab = AppTab.wallet
        @AppStorage(TabEntries.second.rawValue) var secondTab = AppTab.newPost
        @AppStorage(TabEntries.third.rawValue) var thirdTab = AppTab.feed
        @AppStorage(TabEntries.fourth.rawValue) var fourthTab = AppTab.chats
        @AppStorage(TabEntries.fifth.rawValue) var fifthTab = AppTab.profile
    }
    
    private let storage = Storage()
    
    static let shared = AppTabManager()
    
    var tabs: [AppTab] {
        [firstTab, secondTab, thirdTab, fourthTab, fifthTab]
    }
    
    @Published var firstTab: AppTab {
        didSet {
            storage.firstTab = firstTab
        }
    }
    
    @Published var secondTab: AppTab {
        didSet {
            storage.secondTab = secondTab
        }
    }
    
    @Published var thirdTab: AppTab {
        didSet {
            storage.thirdTab = thirdTab
        }
    }
    
    @Published var fourthTab: AppTab {
        didSet {
            storage.fourthTab = fourthTab
        }
    }
    
    @Published var fifthTab: AppTab {
        didSet {
            storage.fifthTab = fifthTab
        }
    }
    
    private init() {
        firstTab = storage.firstTab
        secondTab = storage.secondTab
        thirdTab = storage.thirdTab
        fourthTab = storage.fourthTab
        fifthTab = storage.fifthTab
    }
}
