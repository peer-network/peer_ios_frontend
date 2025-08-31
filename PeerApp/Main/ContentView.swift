//
//  ContentView.swift
//  PeerApp
//
//  Created by Артем Васин on 13.12.24.
//

import SwiftUI
import Environment
import DesignSystem

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var audioManager: AudioSessionManager

    @ObservedObject var appRouter: Router

    @State private var selectedTab: AppTab = .feed

    @State private var selectedTabScrollToTop: Int = -1
    @State private var selectedTabEmptyPath: Int = -1

    @StateObject private var tabManager = AppTabManager.shared
    @StateObject private var popupManager = PopupManager.shared

    var body: some View {
        ZoomContainer {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        ForEach(tabManager.tabs, id: \.self) { tab in
                            tab.makeContentView()
                                .tag(tab)
                        }
                    }

                    if audioManager.currentPlayerObject != nil, !audioManager.isInRestrictedView {
                        FloatingAudioPanelView()
                            .padding(.horizontal, 10)
                            .padding(.bottom, 4)
                            .transition(.move(edge: .bottom).animation(.linear))
                            .animation(.linear, value: audioManager.isInRestrictedView)
                    }
                }

                tabBarView
            }
        }
        .withSheetDestinations(sheetDestinations: $appRouter.presentedSheet)
        .environment(\.selectedTabScrollToTop, selectedTabScrollToTop)
        .environment(\.selectedTabEmptyPath, selectedTabEmptyPath)
        .ignoresSafeArea(.keyboard)
        .overlay {
            if let popupActionType = popupManager.currentActionFeedbackType {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()

                ActionFeedbackPopupView(actionType: popupActionType) {
                    Task {
                        do {
                            try await popupManager.confirmAction?()
                            popupManager.hideActionFeedbackPopup()
                        } catch {
                            showPopup(
                                text: error.userFriendlyDescription
                            )
                        }
                    }
                } cancel: {
                    popupManager.cancelAction?()
                    popupManager.hideActionFeedbackPopup()
                }
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                .transition(.scale.combined(with: .opacity))
                .padding(.horizontal, 20)
            }
        }
        .overlay {
            if popupManager.isShowingFeedbackPrompt {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()

                AppFeedbackPopupView { dontShowAgain in
                    popupManager.setFeedbackDontShowAgain(dontShowAgain)
                } onShareTapped: {
                    openURL(popupManager.feedbackFormURL)
                    popupManager.hideFeedbackPrompt()
                } onDismiss: {
                    popupManager.hideFeedbackPrompt()
                }
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                .transition(.scale.combined(with: .opacity))
                .padding(.horizontal, 20)
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            if activity.webpageURL != nil {
                selectedTab = .feed
            }
        }
        .onOpenURL { url in
            selectedTab = .feed
        }
        .onFirstAppear {
            // Needed to test feedback popups
//            popupManager._resetFeedbackPromptState()

            popupManager.beginFeedbackSession()
            popupManager.scheduleFeedbackPromptIfEligible()
        }
    }

    private var tabBarView: some View {
        HStack(spacing: 0) {
            ForEach(tabManager.tabs, id: \.self) { tab in
                Button {
                    withAnimation {
                        updateTab(with: tab)
                    }
                } label: {
                    Group {
                        if tab == selectedTab {
                            tab.iconFilled
                                .iconSize(height: 22)
                        } else {
                            tab.icon
                                .iconSize(height: 22)
                        }
                    }
                    .foregroundStyle(Colors.whitePrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                }
            }
        }
        .background(Colors.textActive)
    }

    private func updateTab(with newTab: AppTab) {
        HapticManager.shared.fireHaptic(.tabSelection)

        if selectedTab == newTab {
            selectedTabScrollToTop = newTab.rawValue
            selectedTabEmptyPath = newTab.rawValue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTabScrollToTop = -1
                selectedTabEmptyPath = -1
            }
        } else {
            selectedTabScrollToTop = -1
            selectedTabEmptyPath = -1
        }

        selectedTab = newTab
    }
}
