//
//  CheckmarkButton.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct CheckmarkButton: View {
    let text: Text
    @Binding var isChecked: Bool
    let action: (() -> Void)?

    public init(
        text: Text,
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
                        .iconSize(height: 15)
                } else {
                    Icons.checkMarkSqareDisable
                        .iconSize(height: 15)
                }

                text
                    .foregroundStyle(Colors.whiteSecondary)
                    .appFont(.smallLabelRegular)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
