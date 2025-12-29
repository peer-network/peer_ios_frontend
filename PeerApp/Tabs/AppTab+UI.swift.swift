//
//  AppTab+UI.swift.swift
//  PeerApp
//
//  Created by Artem Vasin on 29.12.25.
//

import SwiftUI
import DesignSystem
import Environment

extension AppTab {
    @ViewBuilder
    func makeContentView() -> some View {
        switch self {
        case .feed: FeedTab()
        case .explore: ExploreTab()
        case .newPost: PostCreationTab()
        case .wallet: WalletTab()
        case .profile: ProfileTab()
        }
    }

    var icon: Image {
        switch self {
        case .feed: Icons.house
        case .explore: Icons.magnifyingglass
        case .profile: Icons.person
        case .newPost: Icons.plustSquare
        case .wallet: Icons.wallet
        }
    }

    var iconFilled: Image {
        switch self {
        case .feed: Icons.houseFill
        case .explore: Icons.magnifyingglassFill
        case .profile: Icons.personFill
        case .newPost: Icons.plustSquareFill
        case .wallet: Icons.walletFill
        }
    }
}
