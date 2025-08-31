//
//  AppFeedbackPopupView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 31.08.25.
//

import SwiftUI

public struct AppFeedbackPopupView: View {
    private let onToggleDoNotShowAgain: (Bool) -> Void
    private let onShareTapped: () -> Void
    private let onDismiss: () -> Void

    @State private var dontShowAgain = false

    public init(
        onToggleDoNotShowAgain: @escaping (Bool) -> Void,
        onShareTapped: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onToggleDoNotShowAgain = onToggleDoNotShowAgain
        self.onShareTapped = onShareTapped
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Icons.logoCircleWhite.iconSize(height: 24)

                Text("Got thoughts or ideas?")
                    .font(.custom(.largeTitleBold))

                Spacer()
                    .frame(minWidth: 10)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                Button {
                    onDismiss()
                } label: {
                    Icons.xBold
                        .iconSize(height: 14)
                        .contentShape(.rect)
                }
            }

            Spacer()
                .frame(height: 14)

            Text("Tap the button below to share your feedback.")
                .font(.custom(.bodyRegular))

            Spacer()
                .frame(height: 20)

            let buttonConfig = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Share feedback", icon: Icons.bubbleDots, iconPlacement: .trailing)
            StateButton(config: buttonConfig) {
                onShareTapped()
            }

            Spacer()
                .frame(height: 16)

            Text("You can find the \"Share Feedback\" option in Settings.")
                .font(.custom(.smallLabelRegular))
                .foregroundStyle(Colors.whiteSecondary)

            Spacer()
                .frame(height: 14)

            Button {
                withAnimation {
                    dontShowAgain.toggle()
                    onToggleDoNotShowAgain(dontShowAgain)
                }
            } label: {
                HStack(spacing: 0) {
                    Text("Do not show this message again")
                        .font(.custom(.bodyRegular))

                    Spacer()
                        .frame(width: 10)

                    if dontShowAgain {
                        Icons.checkMarkSqareEnable
                            .iconSize(height: 18)
                    } else {
                        Icons.checkMarkSqareDisable
                            .iconSize(height: 18)
                    }
                }
                .foregroundStyle(dontShowAgain ? Colors.whitePrimary : Colors.whiteSecondary)
                .contentShape(.rect)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .multilineTextAlignment(.leading)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Colors.inactiveDark)
        }
    }
}
