//
//  TabbarEntriesSettingsView.swift
//  Settings
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Environment
import DesignSystem

struct TabbarEntriesSettingsView: View {
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var userPreferences: UserPreferences
    
    @StateObject private var tabs = AppTabManager.shared
    
    var body: some View {
        Form {
            Section {
                Picker("First Tab", selection: $tabs.firstTab) {
                    ForEach(AppTab.allCases) { tab in
                        if tab == tabs.firstTab || !tabs.tabs.contains(tab) {
                            tab.label.tag(tab)
                        }
                    }
                }
                Picker("Second Tab", selection: $tabs.secondTab) {
                    ForEach(AppTab.allCases) { tab in
                        if tab == tabs.secondTab || !tabs.tabs.contains(tab) {
                            tab.label.tag(tab)
                        }
                    }
                }
                Picker("Third Tab", selection: $tabs.thirdTab) {
                    ForEach(AppTab.allCases) { tab in
                        if tab == tabs.thirdTab || !tabs.tabs.contains(tab) {
                            tab.label.tag(tab)
                        }
                    }
                }
                Picker("Fourth Tab", selection: $tabs.fourthTab) {
                    ForEach(AppTab.allCases) { tab in
                        if tab == tabs.fourthTab || !tabs.tabs.contains(tab) {
                            tab.label.tag(tab)
                        }
                    }
                }
                Picker("Fifth Tab", selection: $tabs.fifthTab) {
                    ForEach(AppTab.allCases) { tab in
                        if tab == tabs.fifthTab || !tabs.tabs.contains(tab) {
                            tab.label.tag(tab)
                        }
                    }
                }
            }
            .listRowBackground(theme.primaryBackgroundColor)
            
            Section {
                Toggle("Show Tab Name", isOn: $userPreferences.showTabLabel)
            }
            .listRowBackground(theme.primaryBackgroundColor)
        }
        .navigationTitle("Tabs Customizations")
        .scrollContentBackground(.hidden)
        .background(theme.secondaryBackgroundColor)
    }
}
