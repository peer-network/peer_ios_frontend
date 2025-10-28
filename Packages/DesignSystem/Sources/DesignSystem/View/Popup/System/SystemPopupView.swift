//
//  SystemPopupView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 28.10.25.
//

import SwiftUI

public struct SystemPopupView: View {
    private let type: SystemPopupType
    private let confirmation: () -> Void
    private let cancel: (() -> Void)?

    public init(type: SystemPopupType, confirmation: @escaping () -> Void, cancel: (() -> Void)? = nil) {
        self.type = type
        self.confirmation = confirmation
        self.cancel = cancel
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .foregroundStyle(type.iconBackgroundColor)
                    .frame(width: 50)

                type.icon
                    .iconSize(width: 30, height: 30)
                    .foregroundColor(type.iconColor)
            }
            .padding(.bottom, 10)

            Text(type.title)
                .appFont(.bodyBold)
                .foregroundStyle(type.titleColor)

            if let description = type.description {
                Text(description)
                    .appFont(.smallLabelRegular)
                    .foregroundStyle(Colors.whitePrimary)
                    .padding(.top, 5)
            }

            HStack(spacing: 20) {
                let cancelButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Cancel")
                StateButton(config: cancelButtonConfig) {
                    cancel?()
                }

                StateButton(config: type.confirmationButtonConfig) {
                    confirmation()
                }
            }
            .padding(.top, 20)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}
