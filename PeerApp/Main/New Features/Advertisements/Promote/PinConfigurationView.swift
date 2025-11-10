//
//  PinConfigurationView.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.09.25.
//

import SwiftUI
import Environment
import DesignSystem
import Post

struct PinConfigurationView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel: AdViewModel
    let onBack: () -> Void
    let onNext: () -> Void

    init(viewModel: AdViewModel, onBack: @escaping () -> Void, onNext: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Boost post")
        } content: {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Pinned post configuration")
                    .appFont(.largeTitleBold)
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.bottom, 20)

                RowAdPostView(post: viewModel.post)
                    .padding(.bottom, 30)

                Text("Ad period:")
                    .appFont(.bodyBold)
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.bottom, 15)

                VStack(spacing: 10) {
                    adPeriodRowView(title: "Start", value: "Immediately")

                    adPeriodRowView(title: "Duration", value: "24 hours")

                    adPeriodRowView(title: "Shown", value: "Top of the feed")
                }
                .padding(.bottom, 30)

                Text("Billing summary:")
                    .appFont(.bodyBold)
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.bottom, 15)

                billingRowView
            }
            .padding(20)
            .padding(.bottom, ButtonSize.large.height + 20)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottom) {
            HStack(spacing: 10) {
                let backButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Back")

                StateButton(config: backButtonConfig, action: onBack)

                let nextButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Next")

                StateButton(config: nextButtonConfig, action: onNext)
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
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
                Text(viewModel.adPrice, format: .number)
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
}
