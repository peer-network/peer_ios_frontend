//
//  SuccessView.swift
//  Auth
//
//  Created by Artem Vasin on 25.06.25.
//

import SwiftUI
import DesignSystem

struct SuccessView: View {
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 56) {
            VStack(spacing: 18) {
                icon

                titleText

                descriptionText
            }

            continueButton
        }
    }

    private var icon: some View {
        IconsNew.checkCircle2
            .iconSize(height: 94)
    }

    private var titleText: some View {
        Text(title)
            .appFont(.extraLargeTitleRegular)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionText: some View {
        Text(description)
            .appFont(.bodyRegular)
            .foregroundStyle(Colors.whiteSecondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var continueButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Continue")

        StateButton(config: config) {
            action()
        }
    }
}
