//
//  GemsMainView.swift
//  Wallet
//
//  Created by Artem Vasin on 28.02.25.
//

import SwiftUI
import DesignSystem

struct GemsMainView: View {
    @EnvironmentObject private var viewModel: WalletViewModel

    var body: some View {
        Group {
            switch viewModel.state {
                case .loading(let placeholder):
                    contentView(balance: placeholder, isLoading: true)
                case .display(let balance):
                    contentView(balance: balance, isLoading: false)
                case .error(let error):
                    ErrorView(title: "Error", description: error.localizedDescription) {
                        viewModel.fetchContent()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.fetchContent()
        }
    }

    private func contentView(balance: WalletBalance, isLoading: Bool) -> some View {
        VStack(spacing: 32) {
            Text("Your account")
                .font(.customFont(weight: .regular, style: .callout))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Icons.logoCircleWhite
                        .iconSize(height: 27)

                    Text("\(balance.amount)")
                        .contentTransition(.numericText())
                        .animation(.snappy, value: balance.amount)
                        .font(.customFont(weight: .semiBold, style: .largeTitle))
                        .minimumScaleFactor(0.5)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .skeleton(isRedacted: isLoading ? true : false)
                }

//                balanceExplanationView(balance: balance)
//                    .font(.customFont(weight: .regular, style: .headline))
//                    .skeleton(isRedacted: isLoading ? true : false)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 32)
        }
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
        .padding(20)
        .background(Colors.inactiveDark)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func balanceExplanationView(balance: WalletBalance) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Each token is \(Text(balance.tokenPrice, format: .number.rounded(rule: .up, increment: 0.01)).bold()) €")

            Text("Now you own \(Text(balance.balanceEUR, format: .number.rounded(rule: .up, increment: 0.01)).bold()) €")
                .contentTransition(.numericText())
                .animation(.snappy, value: balance.balanceEUR)
        }
    }
}

#Preview {
    GemsMainView()
        .environmentObject(WalletViewModel())
}
