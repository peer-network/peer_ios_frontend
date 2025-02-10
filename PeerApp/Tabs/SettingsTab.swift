//
//  SettingsTab.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Environment
import DesignSystem
import SFSafeSymbols

struct SettingsTab: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var userPreferences: UserPreferences
    @EnvironmentObject private var theme: Theme
    
    @StateObject private var router = Router()
    
    let isModal: Bool
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Form {
                generalSection
                otherSection
            }
            .scrollContentBackground(.hidden)
            .background(theme.secondaryBackgroundColor)
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(theme.primaryBackgroundColor.opacity(0.30), for: .navigationBar)
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done").bold()
                        }
                    }
                }
            }
            .withAppRouter()
            .withSheetDestinations(sheetDestinations: $router.presentedSheet)
        }
        .withSafariRouter()
        .environmentObject(router)
    }
    
    @ViewBuilder
    private var generalSection: some View {
        Section("General") {
            NavigationLink(value: RouterDestination.settingsTheme) {
                Label("Display Settings", systemSymbol: .paintpalette)
            }
            
            NavigationLink(value: RouterDestination.settingsContent) {
                Label("Content Settings", systemSymbol: .rectangleStack)
            }
            
            NavigationLink(value: RouterDestination.settingsTabs) {
                Label("Tabs Customizations", systemSymbol: .platterFilledBottomIphone)
            }
            
            if HapticManager.shared.supportsHaptics {
                NavigationLink(value: RouterDestination.settingsHaptic) {
                    Label("Haptic Feedback", systemSymbol: .waveformPath)
                }
            }
            
            Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                Label("System Settings", systemSymbol: .gear)
            }
            .tint(theme.labelColor)
        }
        .listRowBackground(theme.primaryBackgroundColor)
    }
    
    @ViewBuilder
    private var otherSection: some View {
        Section("Other") {
            Picker(selection: $userPreferences.preferredBrowser) {
                ForEach(PreferredBrowser.allCases, id: \.rawValue) { browser in
                    switch browser {
                        case .inAppSafari:
                            Text("In-App Browser")
                                .tag(browser)
                        case .safari:
                            Text("System Browser")
                                .tag(browser)
                    }
                }
            } label: {
                Label("Browser", systemSymbol: .network)
            }
            
            Toggle(isOn: $userPreferences.inAppBrowserReaderView) {
                Label("In-App Browser Reader View", systemSymbol: .docPlaintext)
            }
            .disabled(userPreferences.preferredBrowser != PreferredBrowser.inAppSafari)
        }
        .listRowBackground(theme.primaryBackgroundColor)
    }
}
