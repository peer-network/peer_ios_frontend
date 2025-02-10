//
//  DisplaySettingsView.swift
//  PeerApp
//
//  Created by Артем Васин on 06.01.25.
//

import SwiftUI
import DesignSystem
import Environment
//import Feed
import Models

@MainActor
class DisplaySettingsLocalValues: ObservableObject {
    @Published var tintColor = Theme.shared.tintColor
    @Published var primaryBackgroundColor = Theme.shared.primaryBackgroundColor
    @Published var secondaryBackgroundColor = Theme.shared.secondaryBackgroundColor
    @Published var labelColor = Theme.shared.labelColor
    @Published var lineSpacing = Theme.shared.lineSpacing
    @Published var fontSizeScale = Theme.shared.fontSizeScale
}

struct DisplaySettingsView: View {
    typealias FontState = Theme.FontState
    
    @EnvironmentObject private var theme: Theme
    @EnvironmentObject private var userPreferences: UserPreferences
    
    @StateObject private var localValues = DisplaySettingsLocalValues()
    
    @State private var isFontSelectorPresented = false
    
//    private let previewPostViewModel = RowPostViewModel(post: .settingsPlaceholder(), router: Router())
    
    var body: some View {
        VStack {
//            RowPostExternalView(viewModel: previewPostViewModel)
//                .allowsHitTesting(false)
//                .padding(.horizontal, .layoutPadding)
//                .background(theme.primaryBackgroundColor)
//                .cornerRadius(8)
//                .padding(.horizontal, 20)
//                .padding(.top, 20)
//                .background(theme.secondaryBackgroundColor)
            
            Form {
                themeSection
                fontSection
                layoutSection
                resetSection
            }
        }
        .navigationTitle("Display Settings")
        .scrollContentBackground(.hidden)
        .background(theme.secondaryBackgroundColor)
        .task(id: localValues.tintColor) {
            do { try await Task.sleep(for: .microseconds(500)) } catch {}
            theme.tintColor = localValues.tintColor
        }
        .task(id: localValues.primaryBackgroundColor) {
            do { try await Task.sleep(for: .microseconds(500)) } catch {}
            theme.primaryBackgroundColor = localValues.primaryBackgroundColor
        }
        .task(id: localValues.secondaryBackgroundColor) {
            do { try await Task.sleep(for: .microseconds(500)) } catch {}
            theme.secondaryBackgroundColor = localValues.secondaryBackgroundColor
        }
        .task(id: localValues.labelColor) {
            do { try await Task.sleep(for: .microseconds(500)) } catch {}
            theme.labelColor = localValues.labelColor
        }
        .task(id: localValues.lineSpacing) {
            do { try await Task.sleep(for: .microseconds(500)) } catch {}
            theme.lineSpacing = localValues.lineSpacing
        }
        .task(id: localValues.fontSizeScale) {
            do { try await Task.sleep(for: .microseconds(500)) } catch {}
            theme.fontSizeScale = localValues.fontSizeScale
        }
    }
    
    @ViewBuilder
    private var themeSection: some View {
        Section {
            Toggle("Match System", isOn: $theme.followSystemColorScheme)
            themeSelectorButton
            Group {
                ColorPicker("Tint Color", selection: $localValues.tintColor)
                ColorPicker(
                    "Background Color", selection: $localValues.primaryBackgroundColor)
                ColorPicker(
                    "Secondary Background Color",
                    selection: $localValues.secondaryBackgroundColor)
                ColorPicker("Text Color", selection: $localValues.labelColor)
            }
            .disabled(theme.followSystemColorScheme)
            .opacity(theme.followSystemColorScheme ? 0.5 : 1.0)
            .onChange(of: theme.selectedSet) { _ in
                localValues.tintColor = theme.tintColor
                localValues.primaryBackgroundColor = theme.primaryBackgroundColor
                localValues.secondaryBackgroundColor = theme.secondaryBackgroundColor
                localValues.labelColor = theme.labelColor
            }
        } header: {
            Text("Theme")
        } footer: {
            if theme.followSystemColorScheme {
                Text("Custom colors can only be set if match system color scheme is disabled")
            }
        }
        .listRowBackground(theme.primaryBackgroundColor)
    }
    
    private var themeSelectorButton: some View {
        NavigationLink(destination: ThemePreviewView()) {
            HStack {
                Text("Theme")
                Spacer()
                Text(theme.selectedSet.rawValue)
            }
        }
    }
    
    private var fontSection: some View {
        Section("Font") {
            Picker(
                "Timeline Font",
                selection: .init(
                    get: { () -> FontState in
                        if theme.chosenFont?.fontName == "OpenDyslexic-Regular" {
                            return FontState.openDyslexic
                        } else if theme.chosenFont?.fontName == "AtkinsonHyperlegible-Regular" {
                            return FontState.hyperLegible
                        } else if theme.chosenFont?.fontName == ".AppleSystemUIFontRounded-Regular" {
                            return FontState.SFRounded
                        }
                        return theme.chosenFontData != nil ? FontState.custom : FontState.system
                    },
                    set: { newValue in
                        switch newValue {
                            case .system:
                                theme.chosenFont = nil
                            case .openDyslexic:
                                theme.chosenFont = UIFont(name: "OpenDyslexic", size: 1)
                            case .hyperLegible:
                                theme.chosenFont = UIFont(name: "Atkinson Hyperlegible", size: 1)
                            case .SFRounded:
                                theme.chosenFont = UIFont.systemFont(ofSize: 1).rounded()
                            case .custom:
                                isFontSelectorPresented = true
                        }
                    })
            ) {
                ForEach(FontState.allCases, id: \.rawValue) { fontState in
                    Text(fontState.title).tag(fontState)
                }
            }
            .navigationDestination(isPresented: $isFontSelectorPresented, destination: { FontPicker() })
            
            VStack {
                Slider(value: $localValues.fontSizeScale, in: 0.5...1.5, step: 0.1)
                Text("Font Scaling: \(String(format: "%.1f", localValues.fontSizeScale))")
                    .font(.scaledBody)
            }
            .alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading]
            }
            
            VStack {
                Slider(value: $localValues.lineSpacing, in: 0.4...10.0, step: 0.2)
                Text(
                    "Line Spacing: \(String(format: "%.1f", localValues.lineSpacing))"
                )
                .font(.scaledBody)
            }
            .alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading]
            }
        }
        .listRowBackground(theme.primaryBackgroundColor)
    }
    
    @ViewBuilder
    private var layoutSection: some View {
        Section("Display") {
            Picker("Avatar Position", selection: $theme.avatarPosition) {
                ForEach(Theme.AvatarPosition.allCases, id: \.rawValue) { position in
                    Text(position.description).tag(position)
                }
            }
            
            Picker("Avatar Shape", selection: $theme.avatarShape) {
                ForEach(Theme.AvatarShape.allCases, id: \.rawValue) { shape in
                    Text(shape.description).tag(shape)
                }
            }
            
            Picker("Post Action Buttons", selection: $theme.postActionsDisplay) {
                ForEach(Theme.PostActionsDisplay.allCases, id: \.rawValue) { style in
                    Text(style.description).tag(style)
                }
            }
            
            Picker("Post Media Style", selection: $theme.postMediaStyle) {
                ForEach(Theme.PostMediaStyle.allCases, id: \.rawValue) { style in
                    Text(style.description).tag(style)
                }
            }
            
            Toggle("Compact Layout", isOn: $theme.compactLayoutPadding)
        }
        .listRowBackground(theme.primaryBackgroundColor)
    }
    
    private var resetSection: some View {
        Section {
            Button {
                theme.restoreDefault()
            } label: {
                Text("Restore Defaults")
            }
        }
        .listRowBackground(theme.primaryBackgroundColor)
    }
}
