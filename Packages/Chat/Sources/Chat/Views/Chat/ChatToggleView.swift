//
//  ChatToggleView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI

struct ChatToggleView: View {
    @Binding var selectedTab: ChatType
    var onAddTapped: () -> Void
    
    var body: some View {
        HStack(spacing: Constants.Spacing.toggleView) {
            // Private Chat Toggle
            ToggleButton(
                title: Constants.ToggleViewChat.privateTitle,
                isSelected: selectedTab == .privateChat
            ) {
                selectedTab = .privateChat
            }
            
            // Group Chat Toggle
            ToggleButton(
                title: Constants.ToggleViewChat.groupTitle,
                isSelected: selectedTab == .groupChat
            ) {
                selectedTab = .groupChat
            }
            
            Spacer()
            
            // Add Chat Button
            addButton
        }
        .padding(.horizontal, Constants.ToggleViewChatPadding.horizontal)
        .padding(.vertical, Constants.ToggleViewChatPadding.vertical)
    }
    
    private var addButton: some View {
        Button(action: onAddTapped) {
            Image(systemName: Constants.ToggleViewChat.plusTitle)
                .font(Constants.Fonts.buttonFont) // Apply font to icon
                .foregroundColor(Constants.Colors.buttonForeground)
                .frame(width: Constants.ButtonSize.addButton, height: Constants.ButtonSize.addButton)
                .background(
                    Circle()
                        .fill(Constants.Colors.buttonBackground)
                )
        }
        .accessibilityLabel(Constants.ToggleViewChat.addChatAccessibilityButton)
    }
}

