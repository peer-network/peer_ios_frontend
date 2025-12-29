//
//  ContentView.swift
//  PeerApp
//
//  Created by Артем Васин on 13.12.24.
//

import SwiftUI
import Environment
import DesignSystem
import Models
import Analytics

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.analytics) private var analytics

    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var audioManager: AudioSessionManager
    @EnvironmentObject private var appState: AppState

    @ObservedObject var appRouter: Router

    @State private var selectedTab: AppTab = .feed

    @State private var selectedTabScrollToTop: Int = -1
    @State private var selectedTabEmptyPath: Int = -1

    @StateObject private var tabManager = AppTabManager.shared
    @StateObject private var popupManager = PopupManager.shared
    @StateObject private var accountManager = AccountManager.shared

    @StateObject private var systemPopupManager = SystemPopupManager.shared

    private var showIntroBinding: Binding<Bool> {
        Binding(
            get: { !accountManager.shownOnboardings.contains(.intro) },
            set: { isPresented in
                if !isPresented {
                    accountManager.markOnboardingShown(.intro)
                }
            }
        )
    }

    private var showIntroByUserBinding: Binding<Bool> {
        Binding(
            get: { popupManager.isShowingOnboarding },
            set: { isPresented in
                if !isPresented {
                    popupManager.isShowingOnboarding = false
                }
            }
        )
    }

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
        .withSheetDestinations(sheetDestinations: $appRouter.presentedSheet, apiServiceManager: apiManager)
        .environment(\.selectedTabScrollToTop, selectedTabScrollToTop)
        .environment(\.selectedTabEmptyPath, selectedTabEmptyPath)
        .environment(\.tabSwitch, TabSwitchAction { tab in
            withAnimation { updateTab(with: tab) }
        })
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
        .systemPopupOverlay(systemPopupManager)
        .ifCondition(appState.getConstants() != nil) {
            $0.fullScreenCover(isPresented: showIntroBinding) {
                OnboardingView(viewModel: OnboardingViewModel(closeButtonType: .skip, tokenomics: appState.getConstants()!.data.tokenomics, dailyFree: appState.getConstants()!.data.dailyFree, minting: appState.getConstants()!.data.minting, dismissAction: { isSkipped in
                    accountManager.markOnboardingShown(.intro)
                    analytics.track(OnboardingEvent(skipped: isSkipped))
                }))
            }
        }
        .ifCondition(appState.getConstants() != nil) {
            $0.fullScreenCover(isPresented: showIntroByUserBinding) {
                OnboardingView(viewModel: OnboardingViewModel(closeButtonType: .close, tokenomics: appState.getConstants()!.data.tokenomics, dailyFree: appState.getConstants()!.data.dailyFree, minting: appState.getConstants()!.data.minting, dismissAction: { _ in
                    popupManager.isShowingOnboarding = false
                }))
            }
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
