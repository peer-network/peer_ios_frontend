//
//  GemsMainView.swift
//  Wallet
//
//  Created by Artem Vasin on 28.02.25.
//

import SwiftUI
import DesignSystem

struct GemsMainView: View {
    @EnvironmentObject private var walletViewModel: WalletViewModel

    var body: some View {
        VStack(spacing: 32) {
            Text("Your account")
                .font(.customFont(weight: .regular, style: .callout))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Icons.logoCircleWhite
                        .iconSize(height: 27)

                    Text("\(walletViewModel.currentLiquidity)")
                        .font(.customFont(weight: .semiBold, style: .largeTitle))
                }

                let text1 = Text("Each token is ")
                let text2 = Text("0,10 €\n").bold()
                let text3 = Text("Now you own ")
                let text4 = Text(walletViewModel.currentLiquidity * 0.1, format: .number.rounded(rule: .up, increment: 0.01)).bold()
                let text5 = Text(" €").bold()

                (text1 + text2 + text3 + text4 + text5)
                    .font(.customFont(weight: .regular, style: .headline))
            }
            .multilineTextAlignment(.center)
        }
        .foregroundStyle(Colors.whitePrimary)
        .padding(20)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    GemsMainView()
        .environmentObject(WalletViewModel())
}
