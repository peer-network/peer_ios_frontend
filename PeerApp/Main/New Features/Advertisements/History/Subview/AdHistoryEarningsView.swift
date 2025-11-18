//
//  AdHistoryEarningsView.swift
//  PeerApp
//
//  Created by Artem Vasin on 04.11.25.
//

import SwiftUI
import DesignSystem

struct AdHistoryEarningsView: View {
    let gemsAmount: Double
    
    var body: some View {
        HStack(spacing: 0) {
            Text("Earnings")
                .appFont(.bodyRegular)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Icons.gem
                    .iconSize(height: 19)

                Text(gemsAmount, format: .number)
                    .appFont(.largeTitleBold)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
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
            .allowsHitTesting(false)
        }
        .background(Colors.inactiveDark)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
