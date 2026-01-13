//
//  AdHistoryOverviewView.swift
//  PeerApp
//
//  Created by Artem Vasin on 16.10.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models
import Post

struct AdHistoryOverviewView: View {
    @EnvironmentObject private var router: Router

    @StateObject private var viewModel: AdHistoryViewModel

    @State private var viewHeight: CGFloat = .zero

    init(viewModel: AdHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            pageContent
        }
    }
    
    private var pageContent: some View {
        GeometryReader { geo in
            ScrollView {
                adsView
                    .padding(20)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                viewModel.loadStats()
                viewModel.loadAds(reset: true)
            }
            .onAppear {
                viewModel.loadStats()
                viewModel.loadAds(reset: true)
            }
            .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                viewHeight = height
            }
        }
    }

    @ViewBuilder
    private var adsView: some View {
        switch viewModel.state {
            case .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: viewHeight, alignment: .center)
            case .error(let error):
                ErrorView(title: "Error", description: error.userFriendlyDescription) {
                    viewModel.loadStats()
                    viewModel.loadAds(reset: true)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: viewHeight, alignment: .center)
            case .display(let stats):
                adsStatsView(stats)
        }
    }

    @ViewBuilder
    private func adsStatsView(_ stats: AdsStats) -> some View {
        if stats.amountAds == 0 {
            VStack(spacing: 13) {
                Text("You haven’t promoted any posts yet. Start your first promotion to see statistics.")
                    .appFont(.smallLabelRegular)
                    .foregroundStyle(Colors.whiteSecondary)

                let buttonConfig = StateButtonConfig(buttonSize: .small, buttonType: .secondary, title: "Take me to my posts", icon: Icons.arrowNormal, iconPlacement: .trailing)
                StateButton(config: buttonConfig) {
                    router.path.removeLast()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: viewHeight, alignment: .center)
            .multilineTextAlignment(.center)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                AdHistoryEarningsView(gemsAmount: stats.gemsEarned)
                    .padding(.bottom, 10)

                spendingsView(spendings: stats.tokenSpent)
                    .padding(.bottom, 20)

                Text("Interactions")
                    .appFont(.bodyRegular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                AdHistoryInteractionsView(likes: stats.amountLikes, dislikes: stats.amountDislikes, comments: stats.amountComments, views: stats.amountViews, reports: stats.amountReports)
                    .padding(.bottom, 20)

                allAdsTitleView(amount: stats.amountAds)
                    .padding(.bottom, 18)

                listAdsView
            }
            .foregroundStyle(Colors.whitePrimary)}
    }

    private func spendingsView(spendings: Double) -> some View {
        HStack(spacing: 0) {
            Text("Spendings")
                .appFont(.bodyRegular)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Text(spendings, format: .number)
                    .appFont(.bodyBold)

                Icons.logoCircleWhite
                    .iconSize(height: 15)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .modifier(RoundedShapeModifier())
    }

    private func allAdsTitleView(amount: Int) -> some View {
        HStack(spacing: 0) {
            Text("All advertisements")
                .appFont(.bodyRegular)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            Text("Total: \(amount)")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)
        }
    }

    @ViewBuilder
    private var listAdsView: some View {
        if viewModel.ads.isEmpty {
            Text("You don't have any ads yet.")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.ads) { ad in
                    Button {
                        router.navigate(to: RouterDestination.adsHistoryDetails(ad: ad))
                    } label: {
                        RowAdPostViewBig(adStats: ad, showDates: true, showModerationBadge: true)
                            .contentShape(.rect)
                    }
                }

                if viewModel.hasMoreAds {
                    NextPageView {
                        viewModel.loadAds(reset: false)
                    }
                }
            }
        }
    }
}
