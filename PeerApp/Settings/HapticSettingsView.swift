//
//  HapticSettingsView.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import DesignSystem
import Environment

struct HapticSettingsView: View {
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var userPreferences: UserPreferences
    
    var body: some View {
        Form {
            Section {
                Toggle("Feed", isOn: $userPreferences.hapticFeedEnabled)
                Toggle("Tab Selection", isOn: $userPreferences.hapticTabSelectionEnabled)
                Toggle("Button Press", isOn: $userPreferences.hapticButtonPressEnabled)
            }
            .listRowBackground(theme.primaryBackgroundColor)
        }
        .navigationTitle("Haptic Settings")
        .scrollContentBackground(.hidden)
        .background(theme.secondaryBackgroundColor)
    }
}
