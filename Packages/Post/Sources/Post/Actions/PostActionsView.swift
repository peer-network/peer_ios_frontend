//
//  PostActionsView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem
import Environment

struct PostActionsView: View {
    @EnvironmentObject private var router: Router

    enum ActionsLayout {
        case horizontal
        case vertical
    }

    private var actions: [PostAction] {
        [.like, .dislike, .comment, .views]
    }

    let layout: ActionsLayout
    
    @ObservedObject var postViewModel: PostViewModel
    
    var body: some View {
        actionButtonsView
    }
    
    @ViewBuilder
    private var actionButtonsView: some View {
        switch layout {
            case .horizontal:
                ForEach(actions, id: \.self) { action in
                    actionButton(action: action)
                        .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                        .contentShape(.rect)
                }
            case .vertical:
                VStack(alignment: .center, spacing: 0) {
                    ForEach(actions, id: \.self) { action in
                        actionButton(action: action)
                            .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                    }
                }
        }
    }

    @ViewBuilder
    private func actionButton(action: PostAction) -> some View {
        switch layout {
            case .horizontal:
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        Task {
                            do {
                                try await handleAction(action: action)
                            } catch {
                                if let error = error as? PostActionError {
                                    showPopup(
                                        text: error.displayMessage,
                                        icon: error.displayIcon
                                    )
                                } else {
                                    showPopup(
                                        text: error.userFriendlyDescription
                                    )
                                }
                            }
                        }
                    } label: {
                        action.getIcon(viewModel: postViewModel)
                            .iconSize(height: 19)
                            .frame(height: 24)
                            .contentShape(.rect)
                    }

                    if let amount = action.getAmount(viewModel: postViewModel) {
                        Button {
                            if let interaction = action.postInteraction {
                                postViewModel.showInteractions(interaction)
                            } else {
                                Task {
                                    do {
                                        try await handleAction(action: action)
                                    } catch {
                                        if let error = error as? PostActionError {
                                            showPopup(
                                                text: error.displayMessage,
                                                icon: error.displayIcon
                                            )
                                        } else {
                                            showPopup(
                                                text: error.userFriendlyDescription
                                            )
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(amount, format: .number.notation(.compactName))
                                .contentTransition(.numericText())
                                .animation(.snappy, value: amount)
                                .font(.custom(.bodyRegular))
                                .lineLimit(1)
                                .foregroundStyle(action.getDefaultColor())
                                .monospacedDigit()
                                .frame(height: 24)
                                .padding(.trailing, 20)
                                .padding(.leading, 5)
                                .contentShape(.rect)
                        }
                    }
                }
            case .vertical:
                VStack(alignment: .center, spacing: 0) {
                    Button {
                        Task {
                            do {
                                try await handleAction(action: action)
                            } catch {
                                if let error = error as? PostActionError {
                                    showPopup(
                                        text: error.displayMessage,
                                        icon: error.displayIcon
                                    )
                                } else {
                                    showPopup(
                                        text: error.userFriendlyDescription
                                    )
                                }
                            }
                        }
                    } label: {
                        action.getIcon(viewModel: postViewModel)
                            .iconSize(height: 19)
                            .padding(2.5)
                            .padding(.horizontal, 2.5)
                            .contentShape(.rect)
                            .fixedSize(horizontal: true, vertical: true)
                    }

                    if let amount = action.getAmount(viewModel: postViewModel) {
                        Button {
                            if let interaction = action.postInteraction {
                                postViewModel.showInteractions(interaction)
                            } else {
                                Task {
                                    do {
                                        try await handleAction(action: action)
                                    } catch {
                                        if let error = error as? PostActionError {
                                            showPopup(
                                                text: error.displayMessage,
                                                icon: error.displayIcon
                                            )
                                        } else {
                                            showPopup(
                                                text: error.userFriendlyDescription
                                            )
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(amount, format: .number.notation(.compactName))
                                .contentTransition(.numericText())
                                .animation(.snappy, value: amount)
                                .font(.customFont(weight: .regular, size: .body))
                                .lineLimit(1)
                                .foregroundStyle(action.getDefaultColor())
                                .monospacedDigit()
                                .padding(2.5)
                                .padding(.horizontal, 2.5)
                                .padding(.bottom, 10)
                                .contentShape(.rect)
                                .fixedSize(horizontal: true, vertical: true)
                        }
                    }
                }
        }
    }

    private func handleAction(action: PostAction) async throws {
        HapticManager.shared.fireHaptic(.notification(.success))
        switch action {
            case .like:
                if !postViewModel.showIllegalBlur {
                    try await postViewModel.like()
                }
            case .dislike:
                if !postViewModel.showIllegalBlur {
                    try await postViewModel.dislike()
                }
            case .comment:
                postViewModel.showComments()
            case .views:
                postViewModel.showInteractions(.views)
        }
    }
}
