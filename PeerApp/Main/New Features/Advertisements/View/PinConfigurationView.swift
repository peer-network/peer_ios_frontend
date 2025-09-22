//
//  PinConfigurationView.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.09.25.
//

import SwiftUI
import DesignSystem
#if DEBUG
import Environment
import Models
#endif

struct PinConfigurationView: View {
    @StateObject private var viewModel: AdViewModel

    init(viewModel: AdViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                Text("Pinned postconfiguration")
                    .font(.custom(.largeTitleBold))
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.bottom, 20)

                RowPostView(post: viewModel.post)
                    .padding(.bottom, 20)

                Text("Ad period:")
                    .font(.custom(.bodyBold))
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.bottom, 15)

                VStack(spacing: 10) {
                    adPeriodRowView(title: "Start", value: "Immediately")

                    adPeriodRowView(title: "Duration", value: "24 hours")

                    adPeriodRowView(title: "Shown", value: "Top of the feed")
                }
                .padding(.bottom, 30)

                Text("Billing summary:")
                    .font(.custom(.bodyBold))
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.bottom, 15)

                billingRowView
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }

    private func adPeriodRowView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(.bodyRegular))
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .frame(maxWidth: .infinity)

            Text(value)
                .font(.custom(.bodyRegular))
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
                .font(.custom(.bodyRegular))
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .frame(maxWidth: .infinity)

            HStack(spacing: 5) {
                Text("2 000")
                    .font(.custom(.largeTitleBold))
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

//#Preview {
//    PinConfigurationView(viewModel: AdViewModel(post: Post.placeholderText()))
//        .environmentObject(Router())
//        .environmentObject(AccountManager.shared)
//}
