//
//  AdHistoryInteractionsView.swift
//  PeerApp
//
//  Created by Artem Vasin on 04.11.25.
//

import SwiftUI
import Models
import DesignSystem

struct AdHistoryInteractionsView: View {
    let likes: Int
    let dislikes: Int
    let comments: Int
    let views: Int
    let reports: Int

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
                .overlay {
                    interactionView(icon: Icons.heart, name: "Likes", count: likes)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.heartBroke, name: "Dislikes", count: dislikes)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.bubble, name: "Comments", count: comments)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.eyeCircled, name: "Views", count: views)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: IconsNew.exclamaitionMarkCircle, name: "Reports", count: reports)
                }
        }
        .frame(height: 100)
        .modifier(RoundedShapeModifier())
        .lineLimit(1)
    }

    private func interactionView(icon: Image, name: String, count: Int) -> some View {
        VStack(spacing: 0) {
            icon
                .iconSize(height: 15.56)
                .padding(.bottom, 5)

            Text(name)
                .appFont(.smallLabelRegular)
                .padding(.bottom, 10)

            Text(count, format: .number.notation(.compactName))
                .appFont(.bodyBold)
                .foregroundStyle(Colors.whitePrimary)
        }
        .foregroundStyle(Colors.whiteSecondary)
    }

    private var separatorView: some View {
        HStack(spacing: 0) {
            Capsule()
                .frame(width: 1, height: 45)
                .foregroundStyle(Colors.whiteSecondary)
        }
    }
}
