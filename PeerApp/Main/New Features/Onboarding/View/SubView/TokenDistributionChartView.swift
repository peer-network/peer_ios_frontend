//
//  TokenDistributionChartView.swift
//  PeerApp
//
//  Created by Artem Vasin on 03.09.25.
//

import SwiftUI
import Charts
import DesignSystem

private struct UserDistributionData: Identifiable {
    let id = UUID()
    let name: String
    var value: Int
    let color: Color
}

struct TokenDistributionChartView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

//    @State private var distributionData: [UserDistributionData] = []
    @State private var distributionData: [UserDistributionData] = [
        .init(name: "User B", value: 25, color: Color(#colorLiteral(red: 0, green: 0.412, blue: 1, alpha: 1))),
        .init(name: "User A", value: 25, color: Color(#colorLiteral(red: 0.082, green: 0.635, blue: 1, alpha: 1))),
        .init(name: "User C", value: 50, color: Colors.inactiveDark)
    ]

    var body: some View {
        Chart(distributionData, id: \.name) { user in
            SectorMark(
                angle: .value(user.name, user.value),
                innerRadius: .ratio(0.45)
            )
            .foregroundStyle(user.color)
            .annotation(position: .overlay) {
                Text("\(user.value)%")
                    .font(.custom(.bodyBold))
                    .foregroundStyle(Colors.whitePrimary)
                    .rotationEffect(.degrees(-135))
            }
        }
        .chartLegend(.hidden)
        .rotationEffect(.degrees(135))
        .chartBackground { _ in
            VStack(spacing: 0) {
                HStack(spacing: 7) {
                    Text(viewModel.minting.dailyNumberTokens, format: .number)
                        .font(.custom(.largeTitleBold))

                    Icons.logoCircleWhite
                        .iconSize(height: 15)
                }
                .foregroundStyle(Colors.whitePrimary)

                Text("Distributed daily")
                    .padding(.bottom, 9)

                HStack(spacing: 0) {
                    Text("100% of ")
                    Icons.gem
                        .iconSize(height: 9)
                    Text(" Gems")
                }
            }
            .foregroundStyle(Colors.whiteSecondary)
            .font(.custom(.smallLabelRegular))
        }
//        .onFirstAppear {
//            animateChart()
//        }
    }

    private func animateChart() {
        distributionData.append(.init(name: "User B", value: 100, color: Color(#colorLiteral(red: 0, green: 0.412, blue: 1, alpha: 1))))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.smooth) {
                distributionData[0].value = 50
                distributionData.append(.init(name: "User A", value: 50, color: Color(#colorLiteral(red: 0.082, green: 0.635, blue: 1, alpha: 1))))
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.smooth) {
                distributionData[0].value = 25
                distributionData[1].value = 25
                distributionData.append(.init(name: "User C", value: 50, color: Colors.inactiveDark))
            }
        }
    }
}

#Preview {
    TokenDistributionChartView()
        .padding(.horizontal, 35 + 18)
        .background(Colors.blackDark)
}
