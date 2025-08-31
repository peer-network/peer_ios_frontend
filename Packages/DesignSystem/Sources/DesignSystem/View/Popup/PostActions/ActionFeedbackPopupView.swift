//
//  ActionFeedbackPopupView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 16.06.25.
//

import SwiftUI
import Environment

public struct ActionFeedbackPopupView: View {
    private let actionType: ActionFeedbackType
    private let confirmation: () -> Void
    private let cancel: () -> Void

    @AppStorage("enablePostActionsConfirmation", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var enablePostActionsConfirmation = true

    public init(actionType: ActionFeedbackType, confirmation: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.actionType = actionType
        self.confirmation = confirmation
        self.cancel = cancel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                actionType.titleIcon

                Text(actionType.titleText)
                    .font(.customFont(weight: .bold, style: .footnote))
            }
            .foregroundStyle(actionType.titleTintColor)

            if let balance = actionType.currentUserBalance {
                HStack(spacing: 0) {
                    Text("Current balance:")

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    Text(balance, format: .number.precision(.fractionLength(0...2)))
                        .font(.customFont(weight: .bold, style: .callout))

                    Spacer()
                        .frame(width: 10)

                    Icons.logoCircleWhite
                        .iconSize(height: 18)
                }
                .foregroundStyle(Colors.whiteSecondary)
            }

            HStack(spacing: 0) {
                Text(actionType.bodyText)

                Spacer()
                    .frame(minWidth: 10)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                Text(actionType.bodyValue, format: .number.precision(.fractionLength(0...2)))
                    .font(.customFont(weight: .bold, style: .callout))

                if actionType.showTokensLogogInBody {
                    Spacer()
                        .frame(width: 10)
                    
                    Icons.logoCircleWhite
                        .iconSize(height: 18)
                }
            }
            .foregroundStyle(Colors.whiteSecondary)

            Button {
                confirmation()
            } label: {
                Text(actionType.confirmButtonText)
                    .font(.customFont(weight: .bold, style: .footnote))
                    .foregroundStyle(Colors.inactiveDark)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(Colors.whitePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            Button("Cancel") {
                cancel()
            }
            .buttonStyle(StrokeButtonStyle())

            Button {
                withAnimation(.none) {
                    enablePostActionsConfirmation.toggle()
                }
            } label: {
                HStack(spacing: 0) {
                    Text("Do not show this message again")

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    if enablePostActionsConfirmation {
                        Icons.checkMarkSqareDisable
                            .iconSize(height: 18)
                    } else {
                        Icons.checkMarkSqareEnable
                            .iconSize(height: 18)
                    }
                }
                .padding(.horizontal, 20)
                .foregroundStyle(enablePostActionsConfirmation ? Colors.whiteSecondary : Colors.whitePrimary)
                .contentShape(.rect)
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .multilineTextAlignment(.leading)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Colors.inactiveDark)
        }
    }
}

#Preview {
    ActionFeedbackPopupView(actionType: .noFreeComments) {
    } cancel: {
    }
}
