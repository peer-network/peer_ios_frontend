//
//  ShopItemPurchaseView.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.01.26.
//

import SwiftUI
import DesignSystem
import Environment
import NukeUI

struct ShopItemPurchaseView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var flow: ShopPurchaseFlow
    @State private var didStoreFlow = false

    @State private var expandDeliveryInfo: Bool = false

    private enum FocusField: Hashable {
        case name
        case email
        case address1
        case address2
        case city
        case zip
        case country
    }

    @State private var focusedField: FocusField?

    init(item: ShopListing) {
        _flow = StateObject(wrappedValue: ShopPurchaseFlow(item: item))
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Back")
        } content: {
            ZStack(alignment: .bottom) {
                content
                    .multilineTextAlignment(.leading)

                let btnConfig = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Next", icon: IconsNew.arrowRight, iconPlacement: .trailing)
                StateButton(config: btnConfig) {
                    router.navigate(to: ShopRoute.checkout(flowID: flow.id))
                }
                .disabled(!flow.viewModel.canDoPurchase)
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
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.keyboard)
            }
        }
        .onFirstAppear {
            flow.viewModel.apiService = apiManager.apiService
        }
        .onAppear {
            guard !didStoreFlow else { return }
            router.store(flow, id: flow.id)
            didStoreFlow = true
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                itemDescriptionView
                    .padding(.bottom, 20)

                if flow.viewModel.item.item.sizeOption == .sized, let sizes = flow.viewModel.item.item.sizes {
                    sizeSelectionView(sizes: sizes)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 20)
                }

                deliveryInformationView
                    .padding(.bottom, 20)

                addressInformationFormView
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.bottom, ButtonSize.small.height + 20)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private var itemDescriptionView: some View {
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

                HStack(spacing: 0) {
                    Text("Price")
                        .appFont(.bodyRegular)
                        .foregroundStyle(Colors.whiteSecondary)

                    Spacer(minLength: 10)

                    HStack(spacing: 5) {
                        Text(flow.viewModel.item.item.price, format: .number)
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
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                ForEach(sizes.keys.sorted(), id: \.self) { key in
                    let quantity = sizes[key] ?? 0

                    SizeOptionView(name: key, isAvailable: quantity > 0, isSelected: flow.viewModel.selectedSize == key) {
                        flow.viewModel.selectedSize = key
                    }

                    if key != sizes.keys.sorted().last! {
                        Spacer()
                    }
                }
            }
        }
    }

    private var deliveryInformationView: some View {
        Button {
            withAnimation {
                expandDeliveryInfo.toggle()
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Delivery")
                        .appFont(.bodyRegular)
                        .foregroundStyle(Colors.whitePrimary)

                    Spacer(minLength: 5)
                        .layoutPriority(-1)

                    if !expandDeliveryInfo {
                        Text("1-3 working days, **only within Germany**")
                            .appFont(.smallLabelRegular)
                            .lineLimit(1)
                            .padding(.trailing, 5)
                    }

                    Icons.arrowDown
                        .iconSize(width: 16)
                        .rotationEffect(.degrees(expandDeliveryInfo ? 180 : 0))
                        .animation(.easeInOut, value: expandDeliveryInfo)
                }

                if expandDeliveryInfo {
                    Text("We’ll email your delivery details within 1–3 days after your payment is confirmed. Please make sure your email and address are correct, they can’t be changed after you place the order. **Delivery is available only within Germany.**")
                        .appFont(.smallLabelRegular)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .contentShape(.rect)
            .foregroundStyle(Colors.whiteSecondary)
        }
    }

    private var addressInformationFormView: some View {
        VStack(spacing: 10) {
            DataInputTextField(
                leadingIcon: Icons.person,
                text: flow.binding(\.name),
                placeholder: "Name Surname",
                maxLength: 71,
                focusState: $focusedField,
                focusEquals: .name,
                keyboardType: .default,
                textContentType: .name,
                autocapitalization: .words,
                returnKeyType: .next,
                onSubmit: {
                    focusedField = .email
                },
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusedField = nil
                }
            )

            DataInputTextField(
                leadingIcon: IconsNew.envelope,
                text: flow.binding(\.email),
                placeholder: "Email address",
                maxLength: 71,
                focusState: $focusedField,
                focusEquals: .email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                returnKeyType: .next,
                onSubmit: {
                    focusedField = .address1
                },
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusedField = nil
                }
            )

            DataInputTextField(
                leadingIcon: IconsNew.houseLocation,
                text: flow.binding(\.address1),
                placeholder: "Address line 1",
                maxLength: 71,
                focusState: $focusedField,
                focusEquals: .address1,
                keyboardType: .default,
                textContentType: .streetAddressLine1,
                autocapitalization: .words,
                returnKeyType: .next,
                onSubmit: {
                    focusedField = .address2
                },
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusedField = nil
                }
            )

            DataInputTextField(
                leadingIcon: IconsNew.houseLocation,
                text: flow.binding(\.address2),
                placeholder: "Address line 2 (optional)",
                maxLength: 71,
                focusState: $focusedField,
                focusEquals: .address2,
                keyboardType: .default,
                textContentType: .streetAddressLine2,
                autocapitalization: .words,
                returnKeyType: .next,
                onSubmit: {
                    focusedField = .city
                },
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusedField = nil
                }
            )

            HStack(spacing: 10) {
                DataInputTextField(
                    leadingIcon: IconsNew.globe,
                    text: flow.binding(\.city),
                    placeholder: "City",
                    maxLength: 71,
                    focusState: $focusedField,
                    focusEquals: .city,
                    keyboardType: .default,
                    textContentType: .addressCity,
                    autocapitalization: .words,
                    returnKeyType: .next,
                    onSubmit: {
                        focusedField = .zip
                    },
                    toolbarButtonTitle: "Done",
                    onToolbarButtonTap: {
                        focusedField = nil
                    }
                )

                DataInputTextField(
                    text: flow.binding(\.zip),
                    placeholder: "ZIP",
                    maxLength: 71,
                    focusState: $focusedField,
                    focusEquals: .zip,
                    keyboardType: .numberPad,
                    textContentType: .postalCode,
                    autocapitalization: .none,
                    returnKeyType: .next,
                    onSubmit: {
                        focusedField = .country
                    },
                    toolbarButtonTitle: "Done",
                    onToolbarButtonTap: {
                        focusedField = nil
                    }
                )
            }

            DataInputTextField(
                leadingIcon: IconsNew.globe,
                text: flow.binding(\.country),
                placeholder: "Country",
                maxLength: 71,
                focusState: $focusedField,
                focusEquals: .country,
                keyboardType: .default,
                textContentType: .countryName,
                autocapitalization: .words,
                returnKeyType: .done,
                onSubmit: {
                    focusedField = nil
                },
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusedField = nil
                }
            )
        }
    }
}
