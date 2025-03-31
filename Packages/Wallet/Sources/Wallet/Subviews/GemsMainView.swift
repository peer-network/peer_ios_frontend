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

            HStack(spacing: 10) {
                Icons.logoCircleWhite
                    .iconSize(height: 27)

                Text("\(walletViewModel.currentLiquidity)")
                    .font(.customFont(weight: .semiBold, style: .largeTitle))
            }
        }
        .foregroundStyle(Color.white)
        .padding(20)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    GemsMainView()
        .environmentObject(WalletViewModel())
}
