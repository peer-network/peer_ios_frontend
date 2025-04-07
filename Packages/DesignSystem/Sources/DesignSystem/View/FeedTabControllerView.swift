//
//  FeedTabControllerView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 27.02.25.
//

import SwiftUI

public enum FeedPage: CaseIterable {
    case normalFeed
    case videoFeed
    case audioFeed

    var pageIcon: Image {
        switch self {
            case .normalFeed:
                Icons.smile
            case .videoFeed:
                Icons.playRectangle
            case .audioFeed:
                Icons.musicNote
        }
    }
}

public struct FeedTabControllerView: View {
    @Binding public var feedPage: FeedPage

    @Namespace private var tabsNamespace

    public init(feedPage: Binding<FeedPage>) {
        self._feedPage = feedPage
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(FeedPage.allCases, id: \.self) { page in
                ZStack(alignment: .bottom) {
                    Button {
                        feedPage = page
                    } label: {
                        page.pageIcon
                            .iconSize(height: 16)
                            .opacity(feedPage == page ? 1 : 0.5)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity)
                    }

                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.5)

                    if feedPage == page {
                        Capsule()
                            .frame(height: 1)
                            .matchedGeometryEffect(id: "Tab", in: tabsNamespace)
                    }
                }
                .foregroundStyle(Colors.whitePrimary)
                .animation(.default, value: feedPage)
            }
        }
        .background(Colors.textActive)
    }
}

#Preview {
    FeedTabControllerView(feedPage: .constant(.normalFeed))
}
