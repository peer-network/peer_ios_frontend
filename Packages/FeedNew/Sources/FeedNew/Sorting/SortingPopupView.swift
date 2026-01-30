//
//  SortingPopupView.swift
//  FeedNew
//
//  Created by Artem Vasin on 17.03.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment

struct SortingPopupView: View {
    @StateObject private var feedContentSortingAndFiltering = FeedContentSortingAndFiltering.shared

    var body: some View {
        PopupTransparentStyleView {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(FeedFilterByRelationship.allCases, id: \.self) {
                        filterButton($0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                    .frame(width: 10)

                VStack(spacing: 10) {
                    sortByPopularityButton()
                    sortByTimeButton()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func filterButton(_ type: FeedFilterByRelationship) -> some View {
        Button {
            withAnimation {
                feedContentSortingAndFiltering.filterByRelationship = type
            }
        } label: {
            Text(type.rawValue)
                .font(.customFont(weight: .regular, style: .footnote))
                .ifCondition(feedContentSortingAndFiltering.filterByRelationship == type) {
                    $0.bold()
                }
                .foregroundStyle(Colors.whitePrimary)
        }
    }

    private func sortByPopularityButton() -> some View {
        Menu {
            ForEach(FeedContentSortingByPopularity.allCases, id: \.self) { value in
                Button(value.rawValue) {
                    withAnimation {
                        feedContentSortingAndFiltering.sortByPopularity = value
                    }
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text(feedContentSortingAndFiltering.sortByPopularity.rawValue)
                    .font(.customFont(weight: .regular, style: .footnote))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize()

                Spacer()
                    .frame(minWidth: 10)

                Icons.arrowDownNormal
                    .iconSize(height: 12)
                    .fixedSize()
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Colors.whitePrimary, lineWidth: 1)
            }
        }
    }

    private func sortByTimeButton() -> some View {
        Menu {
            ForEach(FeedContentSortingByTime.allCases, id: \.self) { value in
                Button(value.rawValue) {
                    withAnimation {
                        feedContentSortingAndFiltering.sortByTime = value
                    }
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text(feedContentSortingAndFiltering.sortByTime.rawValue)
                    .font(.customFont(weight: .regular, style: .footnote))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize()

                Spacer()
                    .frame(minWidth: 10)

                Icons.arrowDownNormal
                    .iconSize(height: 12)
                    .fixedSize()
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Colors.whitePrimary, lineWidth: 1)
            }
        }
    }
}

#Preview {
    SortingPopupView()
}
