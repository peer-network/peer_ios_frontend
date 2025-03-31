//
//  Tabs.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import DesignSystem

enum AppTab: Int, Identifiable, CaseIterable {
    case feed
    case explore
    case newPost
    case wallet
    case profile

    var id: Int {
        rawValue
    }
    
    @ViewBuilder
    func makeContentView() -> some View {
        switch self {
            case .feed:
                FeedTab()
            case .explore:
                ExploreTab()
            case .newPost:
                PostCreationTab()
            case .profile:
                ProfileTab()
            case .wallet:
                WalletTab()
        }
    }
    
    var icon: Image {
        switch self {
            case .feed:
                Icons.house
            case .explore:
                Icons.magnifyingglass
            case .profile:
                Icons.person
            case .newPost:
                Icons.plustSquare
            case .wallet:
                Icons.wallet
        }
    }

    var iconFilled: Image {
        switch self {
            case .feed:
                Icons.houseFill
            case .explore:
                Icons.magnifyingglassFill
            case .profile:
                Icons.personFill
            case .newPost:
                Icons.plustSquareFill
            case .wallet:
                Icons.walletFill
        }
    }
}

final class AppTabManager: ObservableObject {
    enum TabEntries: String {
        case first, second, third, fourth, fifth
    }
    
    class Storage {
        @AppStorage(TabEntries.first.rawValue) var firstTab = AppTab.feed
        @AppStorage(TabEntries.second.rawValue) var secondTab = AppTab.explore
        @AppStorage(TabEntries.third.rawValue) var thirdTab = AppTab.newPost
        @AppStorage(TabEntries.fourth.rawValue) var fourthTab = AppTab.wallet
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
