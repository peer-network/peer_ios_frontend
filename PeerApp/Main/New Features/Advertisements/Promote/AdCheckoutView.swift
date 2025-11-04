//
//  AdCheckoutView.swift
//  PeerApp
//
//  Created by Artem Vasin on 15.10.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

struct AdCheckoutView: View {
    @ObservedObject var viewModel: AdViewModel
    let onBack: () -> Void
    let onPay:  () async -> Void

    @State private var expandDistribution: Bool = false

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Pinned post")
        } content: {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Promote your post")
                    .appFont(.largeTitleBold)
                    .foregroundStyle(Colors.whitePrimary)

                availableTokensView

                pricingView

                Text(viewModel.hasEnoughTokens ? "Ready to launch? Click 'Pay' to promote your post." : "You don’t have enough Peer Tokens to start this promotion.")
                    .appFont(.bodyRegular)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(viewModel.hasEnoughTokens ? Colors.whiteSecondary : Colors.redAccent)
            }
            .padding(20)
            .padding(.bottom, ButtonSize.large.height + 20)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottom) {
            HStack(spacing: 10) {
                let clearButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Back")

                StateButton(config: clearButtonConfig, action: onBack)

                let postButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Pay")

                AsyncStateButton(config: postButtonConfig, action: onPay)
                    .disabled(!viewModel.hasEnoughTokens)
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

    private var pricingView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0) {
                Text("Promotion cost")
                    .appFont(.largeTitleRegular)

                Spacer()
                    .frame(minWidth: 10)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                HStack(spacing: 10) {
                    Text(viewModel.adPrice, format: .number)
                        .appFont(.extraLargeTitleBold)

                    Icons.logoCircleWhite
                        .iconSize(height: 24)
                }
            }

            Capsule()
                .frame(height: 1)
                .foregroundStyle(Colors.whiteSecondary)

            Button {
                withAnimation {
                    expandDistribution.toggle()
                }
            } label: {
                HStack(spacing: 0) {
                    Text("Fees included")
                        .appFont(.bodyRegular)

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                        Icons.arrowDown
                            .iconSize(height: 8)
                            .rotationEffect(expandDistribution ? .degrees(180) : .degrees(0))
                }
                .contentShape(.rect)
            }

            if expandDistribution {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 0) {
                        Text("Peer Bank (\(viewModel.peerFee.percent)%)")
                            .appFont(.bodyRegular)
                            .foregroundStyle(Colors.whiteSecondary)

                        Spacer()
                            .frame(minWidth: 10)
                            .frame(maxWidth: .infinity)
                            .layoutPriority(-1)

                        HStack(spacing: 5) {
                            Text(viewModel.peerFee.amount, format: .number)
                                .appFont(.bodyRegular)

                            Icons.logoCircleWhite
                                .iconSize(height: 12)
                        }
                    }

                    if AccountManager.shared.inviter != nil {
                        HStack(spacing: 0) {
                            Text("To the inviter (\(viewModel.inviterFee.percent)%)")
                                .appFont(.bodyRegular)
                                .foregroundStyle(Colors.whiteSecondary)

                            Spacer()
                                .frame(minWidth: 10)
                                .frame(maxWidth: .infinity)
                                .layoutPriority(-1)

                            HStack(spacing: 5) {
                                Text(viewModel.inviterFee.amount, format: .number)
                                    .appFont(.bodyRegular)

                                Icons.logoCircleWhite
                                    .iconSize(height: 12)
                            }
                        }
                    }

                    HStack(spacing: 0) {
                        Text("Burn (\(viewModel.burnFee.percent)%)")
                            .appFont(.bodyRegular)
                            .foregroundStyle(Colors.whiteSecondary)

                        Spacer()
                            .frame(minWidth: 10)
                            .frame(maxWidth: .infinity)
                            .layoutPriority(-1)

                        HStack(spacing: 5) {
                            Text(viewModel.burnFee.amount, format: .number)
                                .appFont(.bodyRegular)

                            Icons.logoCircleWhite
                                .iconSize(height: 12)
                        }
                    }
                }
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Colors.inactiveDark)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var availableTokensView: some View {
        HStack(spacing: 0) {
            Text("Your Balance")
                .appFont(.smallLabelRegular)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.version)
                }

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Text(viewModel.balance, format: .number)
                    .appFont(.bodyBold)

                Icons.logoCircleWhite
                    .iconSize(height: 13)
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 54)
        .foregroundStyle(Colors.whitePrimary)
        .background {
            ZStack {
                Ellipse()
                    .fill(Gradients.walletBG1)
                    .frame(width: 265, height: 220)
                    .offset(x: 192, y: -59)
                    .blur(radius: 10)

                Ellipse()
                    .fill(Gradients.walletBG2)
                    .frame(width: 479, height: 208)
                    .offset(x: -114, y: 7)
                    .blur(radius: 10)
            }
            .ignoresSafeArea()
        }
        .background(Colors.blackDark)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
