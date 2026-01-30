//
//  FeedSearchBarView.swift
//  FeedNew
//
//  Created by Artem Vasin on 14.01.26.
//

import SwiftUI
import DesignSystem
import Environment

struct FeedSearchBarView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        HStack(spacing: 10) {
            typeButton(.username)

            typeButton(.tag)

            typeButton(.title)

            Spacer(minLength: 10)

            Icons.magnifyingglass
                .iconSize(height: 22)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.trailing, 10)
        }
        .frame(height: 50)
        .padding(.horizontal, 5)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(Colors.whitePrimary, lineWidth: 1)
        }
    }

    private func typeButton(_ type: SearchType) -> some View {
        Button {
            router.navigate(to: RouterDestination.search(type: type))
        } label: {
            Text(type.rawValue)
                .ifCondition(type == .username) {
                    $0
                        .appFont(.bodyBoldItalic)
                        .foregroundColor(.black)
                }
                .ifCondition(type == .tag) {
                    $0
                        .appFont(.bodyRegular)
                        .foregroundColor(Colors.hashtag)
                }
                .ifCondition(type == .title) {
                    $0
                        .appFont(.bodyRegular)
                        .foregroundColor(Color.black)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.whitePrimary)
                }
        }
    }
}
