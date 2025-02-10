//
//  ContentSettingsView.swift
//  PeerApp
//
//  Created by Артем Васин on 07.01.25.
//

import SwiftUI
import DesignSystem
import Environment
import Feed
import SFSafeSymbols

struct ContentSettingsView: View {
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var userPreferences: UserPreferences
    
    @StateObject private var contentFilter = FeedContentFilter.shared
    
    var body: some View {
        Form {
            Section("Media") {
                Toggle(isOn: $userPreferences.autoPlayVideo) {
                    Text("Auto Play Videos")
                }
                Toggle(isOn: $userPreferences.muteVideo) {
                    Text("Mute Videos")
                }
            }
            .listRowBackground(theme.primaryBackgroundColor)
            
            Section {
                Toggle(isOn: $userPreferences.collapseLongPosts) {
                    Text("Collapse Long Posts")
                }
            } header: {
                Text("Reading")
            } footer: {
                Text("Collapsed posts only display a limited number of lines together with a button to show the full post")
            }
            .listRowBackground(theme.primaryBackgroundColor)
            
            Section("Content Filter") {
                Toggle(isOn: $contentFilter.showText) {
                    Label("Text Posts", systemSymbol: .textAlignleft)
                }
                Toggle(isOn: $contentFilter.showPhoto) {
                    Label("Image Posts", systemSymbol: .photo)
                }
                Toggle(isOn: $contentFilter.showVideo) {
                    Label("Video Posts", systemSymbol: .playRectangle)
                }
                Toggle(isOn: $contentFilter.showAudio) {
                    Label("Audio Posts", systemSymbol: .waveform)
                }
            }
            .listRowBackground(theme.primaryBackgroundColor)
        }
        .navigationTitle("Content Settings")
        .scrollContentBackground(.hidden)
        .background(theme.secondaryBackgroundColor)
    }
}
