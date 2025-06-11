//
//  ToggleButton.swift
//  Chat
//
//  Created by Siva kumar Aketi on 10/06/25.
//

import SwiftUI

struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
               // .font(Constants.Fonts.toggleFont, weight: .bold) // Apply custom font
                .font(.system(size: Constants.FontSize.toggleButton,
                                           weight: .bold))
                .foregroundColor(isSelected ? Constants.Colors.selectedText : Constants.Colors.unselectedText)
                .frame(height: Constants.ButtonSize.toggleHeight)
                .padding(.horizontal, Constants.ToggleViewChatPadding.toggleHorizontal)
                .background(
                    isSelected ? Constants.Colors.selectedBackground : Constants.Colors.unselectedBackground
                )
                .clipShape(Capsule())
        }
        .accessibilityHint(Constants.ToggleViewChat.toggleAccessibilityButtonHint)
    }
}
