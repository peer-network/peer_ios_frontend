//
//  TransactionsListView.swift
//  Wallet
//
//  Created by Artem Vasin on 24.11.25.
//

import SwiftUI
import DesignSystem

struct TransactionsListView: View {
    let arrowAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                arrowAction()
            } label: {
                HStack(spacing: 0) {
                    Text("Transactions")
                        .appFont(.bodyBold)

                    Spacer()
                        .frame(minWidth: 0)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    Icons.arrowDown
                        .iconSize(height: 8)
                }
                .foregroundStyle(Colors.whitePrimary)
                .padding(.vertical, 10)
                .contentShape(.rect)
            }

            ForEach(0..<100) { i in
                Text("Example \(i)")
                    .font(.title)
                    .frame(width: 200, height: 200)
                    .background(Colors.passwordBarsGreen)
            }
        }
    }
}
