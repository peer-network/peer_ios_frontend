//
//  CheckmarkButton.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct CheckmarkButton: View {
    let text: String
    @Binding var isChecked: Bool
    let action: (() -> Void)?

    public init(
        text: String,
        isChecked: Binding<Bool>,
        action: (() -> Void)? = nil
    ) {
        self._isChecked = isChecked
        self.text = text
        self.action = action
    }

    public var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isChecked.toggle()
            }
            action?()
        } label: {
            HStack(spacing: 6) {
                if isChecked {
                    Icons.checkMarkSqareEnable
                        .iconSize(height: 18)
                } else {
                    Icons.checkMarkSqareDisable
                        .iconSize(height: 18)
                }

                Text(text)
                    .appFont(.smallLabelRegular)
                    .foregroundStyle(isChecked ? Colors.whitePrimary : Colors.whiteSecondary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
