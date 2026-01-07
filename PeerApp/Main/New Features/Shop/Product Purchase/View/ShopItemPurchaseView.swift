//
//  ShopItemPurchaseView.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.01.26.
//

import SwiftUI
import DesignSystem
import Environment

struct ShopItemPurchaseView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel: ShopItemPurchaseViewModel

    @State private var selectedSize: String?

    init(viewModel: ShopItemPurchaseViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            content
                .multilineTextAlignment(.leading)
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                itemDescriptionView
                    .padding(.bottom, 20)

                if viewModel.item.item.sizeOption == .sized, let sizes = viewModel.item.item.sizes {
                    sizeSelectionView(sizes: sizes)
                        .padding(.bottom, 20)
                }

                deliveryInformationView
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }

    private var itemDescriptionView: some View {
        HStack(spacing: 10) {
            // TODO: image here

            VStack(spacing: 5) {
                Text(viewModel.item.item.name)
                    .appFont(.bodyBold)
                    .foregroundStyle(Colors.whitePrimary)

                Text(viewModel.item.item.description)
                    .appFont(.bodyRegular)
                    .foregroundStyle(Colors.whiteSecondary)

                HStack(spacing: 0) {
                    Text("Price")
                        .appFont(.bodyRegular)
                        .foregroundStyle(Colors.whiteSecondary)

                    Spacer(minLength: 10)

                    HStack(spacing: 5) {
                        Text(viewModel.item.item.price, format: .number)
                            .appFont(.largeTitleBold)

                        Icons.logoCircleWhite
                            .iconSize(height: 18.33)
                    }
                    .foregroundStyle(Colors.whitePrimary)
                }
                .padding(.horizontal, 20)
                .frame(height: 45)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(Colors.inactiveDark)
                }
            }
        }
    }

    private func sizeSelectionView(sizes: [String: Int]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select size")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)

            HStack(spacing: 0) {
                ForEach(sizes.keys.sorted(), id: \.self) { key in
                    let quantity = sizes[key] ?? 0

                    SizeOptionView(name: key, isAvailable: quantity > 0, isSelected: selectedSize == key) {
                        selectedSize = key
                    }
                }
            }
        }
    }

    private var deliveryInformationView: some View {
        VStack(spacing: 0) {

        }
    }
}
