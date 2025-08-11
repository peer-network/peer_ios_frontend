//
//  InteractionsHeaderView.swift
//  Post
//
//  Created by Artem Vasin on 05.08.25.
//

import SwiftUI
import DesignSystem

struct InteractionsHeaderView: View {
    @Binding public var interactionsPage: InteractionType

    @ObservedObject var viewModel: PostViewModel

    @Namespace private var interactionsTabNamespace

    let interactions: [InteractionType]

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(interactions, id: \.self) { interaction in
                    Button {
                        interactionsPage = interaction
                    } label: {
                        VStack(alignment: .center, spacing: 0) {
                            HStack(spacing: 7) {
                                interaction.icon

                                if let amount = interaction.getAmount(viewModel: viewModel) {
                                    Text(amount, format: .number.notation(.compactName))
                                        .font(.customFont(weight: .regular, size: .body))
                                        .lineLimit(1)
                                        .monospacedDigit()
                                }
                            }
                            .padding(.horizontal, 15)

                            if interactionsPage == interaction {
                                RoundedRectangle(cornerRadius: 24)
                                    .frame(height: 1)
                                    .matchedGeometryEffect(id: "Interaction", in: interactionsTabNamespace)
                                    .padding(.top, 14)
                            } else {
                                Spacer()
                                    .frame(height: 15)
                            }
                        }
                        .opacity(interactionsPage == interaction ? 1 : 0.5)
                        .padding(.top, 10)
                        .contentShape(.rect)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
            }
            .animation(.default, value: interactionsPage)
            .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 24)
                .frame(height: 1)
                .opacity(0.5)
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}
