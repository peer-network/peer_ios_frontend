//
//  ShopItemCheckoutView.swift
//  PeerApp
//
//  Created by Artem Vasin on 12.01.26.
//

import SwiftUI
import DesignSystem
import NukeUI
import Environment

struct ShopItemCheckoutView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var appState: AppState

    @EnvironmentObject private var flow: ShopPurchaseFlow

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Back")
        } content: {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                titleView
                    .padding(.bottom, 20)

                itemView
                    .padding(.bottom, 20)

                deilveryView
                    .padding(.bottom, 10)

                CheckoutTotalAmountView(
                    model: CheckoutAmount(tokenomics: appState.getConstants()!.data.tokenomics, baseAmount: Decimal(flow.viewModel.item.item.price), areFeesIncluded: true, hasInviter: AccountManager.shared.inviter != nil),
                    basePurposeText: "Item price",
                    feesText: "Fees included"
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.bottom, ButtonSize.small.height + 20)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .overlay(alignment: .bottom) {
            HStack(spacing: 10) {
                let backButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Back")

                StateButton(config: backButtonConfig) {
                    router.pop()
                }

                let payButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Pay")

                AsyncStateButton(config: payButtonConfig) {

                }
            }
            .padding(20)
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

    private var titleView: some View {
        Text("Verify details")
            .appFont(.largeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var itemView: some View {
        HStack(spacing: 10) {
            LazyImage(url: flow.viewModel.item.post.mediaURLs.first) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: 112,
                            height: 112
                        )
                        .clipShape(Rectangle())
                } else {
                    Colors.blackDark
                }
            }
            .frame(width: 112, height: 112)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            VStack(spacing: 5) {
                Text(flow.viewModel.item.item.name)
                    .appFont(.bodyBold)
                    .foregroundStyle(Colors.whitePrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(flow.viewModel.item.item.description)
                    .appFont(.bodyRegular)
                    .foregroundStyle(Colors.whiteSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 10)
                    .layoutPriority(-1)

                if let selectedSize = flow.viewModel.selectedSize {
                    HStack(spacing: 20) {
                        Text("Size")
                            .appFont(.bodyRegular)
                            .foregroundStyle(Colors.whiteSecondary)

                        SizeOptionView(name: selectedSize, isAvailable: true, isSelected: true) {}
                            .disabled(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }

    private var deilveryView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                IconsNew.dropPin
                    .iconSize(height: 15)

                Text("Delivery information")
                    .appFont(.smallLabelBold)
            }
            .foregroundStyle(Colors.whitePrimary)
            .frame(maxWidth: .infinity, alignment: .leading)

            Capsule()
                .frame(height: 1)
                .foregroundStyle(Colors.whiteSecondary)

            addressLineView(title: "Name", value: flow.viewModel.name)

            addressLineView(title: "E-mail", value: flow.viewModel.email)

            addressLineView(title: "Address line 1", value: flow.viewModel.address1)

            if !flow.viewModel.address2.isEmpty {
                addressLineView(title: "Address line 2", value: flow.viewModel.address2)
            }

            addressLineView(title: "City", value: flow.viewModel.city)

            addressLineView(title: "ZIP code", value: flow.viewModel.zip)

            addressLineView(title: "Country", value: flow.viewModel.country)
        }
        .padding(20)
        .background(Colors.inactiveDark)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func addressLineView(title: String, value: String) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .foregroundStyle(Colors.whiteSecondary)

            Spacer(minLength: 5)
                .layoutPriority(-1)

            Text(value)
                .foregroundStyle(Colors.whitePrimary)
        }
        .appFont(.smallLabelRegular)
    }
}
