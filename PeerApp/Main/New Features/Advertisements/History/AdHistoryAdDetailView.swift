//
//  AdHistoryAdDetailView.swift
//  PeerApp
//
//  Created by Artem Vasin on 04.11.25.
//

import SwiftUI
import Environment
import Models
import DesignSystem
import Post

struct AdHistoryAdDetailView: View {
    @EnvironmentObject private var router: Router
    
    let ad: SingleAdStats

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            pageContent
        }
    }

    private var pageContent: some View {
        ScrollView {
            adView
                .padding(20)
        }
        .scrollIndicators(.hidden)
    }

    private var adView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pin post statistics")
                .appFont(.largeTitleRegular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

            if ad.post.visibilityStatus == .hidden {
                HiddenBadgeLongView()
                    .padding(.bottom, 10)
            } else if ad.post.visibilityStatus == .illegal {
                IllegalBadgeLongView()
                    .padding(.bottom, 10)
            }

          Button {
                router.navigate(to: RouterDestination.postDetailsWithPost(post: ad.post))
            } label: {
                RowAdPostViewBig(adStats: ad, showDates: false, showModerationBadge: false)
                    .contentShape(.rect)
            }
            .padding(.bottom, 10)

            AdHistoryEarningsView(gemsAmount: ad.gemsEarned)
                .padding(.bottom, 20)

            Text("Interactions")
                .appFont(.bodyRegular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

            AdHistoryInteractionsView(likes: ad.amountLikes, dislikes: ad.amountDislikes, comments: ad.amountComments, views: ad.amountViews, reports: ad.amountReports)
                .padding(.bottom, 20)

            adPeriodRowView(title: "Start date", value: convertUTCToLocalDate(ad.startDate) ?? "")
                .padding(.bottom, 10)

            adPeriodRowView(title: "End date", value: convertUTCToLocalDate(ad.endDate) ?? "")
                .padding(.bottom, 10)

            billingRowView
        }
    }

    private func adPeriodRowView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            Text(value)
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var billingRowView: some View {
        HStack {
            Text("Total ad cost")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Text(ad.tokenCost, format: .number)
                    .appFont(.largeTitleBold)
                    .foregroundStyle(Colors.whitePrimary)

                Icons.logoCircleWhite
                    .iconSize(height: 16)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private func convertUTCToLocalDate(_ utcDateString: String) -> String? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        guard let date = dateFormatter.date(from: utcDateString) else {
            return nil
        }

        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: date)
    }
}

struct HiddenBadgeLongView: View {
    var body: some View {
        HStack(spacing: 0) {
            IconsNew.eyeWithSlash
                .iconSize(height: 15)
                .padding(.trailing, 7)

            Text("Hidden")
                .appFont(.smallLabelRegular)
                .lineLimit(1)

            Spacer()
                .frame(minHeight: 2)
                .frame(maxHeight: .infinity)
                .layoutPriority(-1)

            Text("This post is shown as sensitive content")
                .appFont(.smallLabelRegular)
                .lineLimit(1)
        }
        .foregroundStyle(Colors.whiteSecondary)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}

struct IllegalBadgeLongView: View {
    var body: some View {
        Text("The post is removed as illegal")
            .appFont(.smallLabelRegular)
            .lineLimit(1)
            .foregroundStyle(Colors.whiteSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(Colors.inactiveDark)
            }
    }
}
