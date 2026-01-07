//
//  SizeOptionView.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.01.26.
//

import SwiftUI
import DesignSystem

struct SizeOptionView: View {
    let name: String
    let isAvailable: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(name)
                .appFont(isSelected ? .bodyBold : .bodyRegular)
                .foregroundStyle(isAvailable ? Colors.whitePrimary : Colors.whiteSecondary)
                .frame(height: 45)
                .frame(minWidth: 45)
                .background {
                    if isSelected {
                        Colors.hashtag
                    } else {
                        if isAvailable {
                            Colors.blackDark
                        } else {
                            Colors.inactiveDark
                        }
                    }
                }
                .ifCondition(isAvailable) {
                    $0.overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(.rect)
        }
        .disabled(!isAvailable)
    }
}

#Preview {
    HStack {
        SizeOptionView(name: "M", isAvailable: true, isSelected: false, action: {})
        SizeOptionView(name: "XXL", isAvailable: true, isSelected: true, action: {})
        SizeOptionView(name: "XXXXXL", isAvailable: false, isSelected: false, action: {})
    }
}
