//
//  VersionHistoryPageView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 07.04.25.
//

import SwiftUI
import Environment

public struct VersionHistoryPageView: View {

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Version History")
        } content: {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("5.0.0")
                            .font(.customFont(weight: .bold, size: .title))
                        Text("""
                                - Views are being counted
                                - Audio feed is released
                                - Short videos are fixed
                                - Sent comments are displayed immediately
                                - Amount of friends is displayed
                                """)
                    }

                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.5)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("5.0.0")
                            .font(.customFont(weight: .bold, size: .title))
                        Text("""
                        - Views are being counted
                        - Audio feed is released
                        - Short videos are fixed
                        - Sent comments are displayed immediately
                        - Amount of friends is displayed
                        """)
                    }
                }
                .padding(20)
                .foregroundStyle(Colors.whitePrimary)
                .font(.customFont(weight: .regular, size: .body))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    VersionHistoryPageView()
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
