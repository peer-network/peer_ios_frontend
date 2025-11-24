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
        VStack(spacing: 10) {
            Text("Available balance")
                .appFont(.smallLabelRegular)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                Text("\(balance.amount)")
                    .contentTransition(.numericText())
                    .animation(.snappy, value: balance.amount)
                    .appFont(.extraLargeTitleBold)
                    .minimumScaleFactor(0.5)
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .skeleton(isRedacted: isLoading ? true : false)

                Icons.logoCircleWhite
                    .iconSize(height: 27)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .padding(20)
        .background {
            ZStack {
                Ellipse()
                    .fill(Gradients.walletBG1)
                    .frame(width: 265, height: 220)
                    .padding(.bottom, 54)
                    .padding(.leading, 306)
                    .blur(radius: 10)

                Ellipse()
                    .fill(Gradients.walletBG2)
                    .frame(width: 479, height: 208)
                    .padding(.top, 66)
                    .padding(.trailing, 92)
                    .blur(radius: 10)
            }
            .frame(width: 571, height: 274)
            .position(x: 171.5, y: 78)
            .ignoresSafeArea()
            .clipped()
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    GemsMainView()
        .environmentObject(WalletViewModel())
}
