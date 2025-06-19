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
        [.like, .dislike, .comment, .views, .menu]
    }

    let layout: ActionsLayout

    @ObservedObject var postViewModel: PostViewModel

    @Binding var showAppleTranslation: Bool

    var body: some View {
        actionButtonsView
    }

    @ViewBuilder
    private var actionButtonsView: some View {
        switch layout {
            case .horizontal:
                HStack(alignment: .center, spacing: 20) {
                    ForEach(actions, id: \.self) { action in
                        if action == .menu {
                            Spacer()
                                .frame(maxWidth: .infinity)
                                .layoutPriority(-1)

                            Menu {
                                Section {
                                    Button {
                                        showAppleTranslation = true
                                    } label: {
                                        Label("Translate", systemImage: "captions.bubble")
                                    }

                                    if !AccountManager.shared.isCurrentUser(id: postViewModel.post.owner.id) {
                                        Button(role: .destructive) {
                                            Task {
                                                do {
                                                    try await postViewModel.report()
                                                    showPopup(text: "Post was reported.")
                                                } catch let error as PostActionError {
                                                    showPopup(
                                                        text: error.displayMessage,
                                                        icon: error.displayIcon
                                                    )
                                                }
                                            }
                                        } label: {
                                            Label("Report Post", systemImage: "exclamationmark.bubble")
                                        }

                                        Button(role: .destructive) {
                                            Task {
                                                do {
                                                    let isBlocked = try await postViewModel.blockContent()
                                                    if isBlocked {
                                                        showPopup(text: "User's content will be hidden.")
                                                    } else {
                                                        showPopup(text: "User's content will be visible.")
                                                    }
                                                } catch {
                                                    showPopup(
                                                        text: error.userFriendlyDescription
                                                    )
                                                }
                                            }
                                        } label: {
                                            Label("Hide Content from Feed", systemImage: "person.slash.fill")
                                        }
                                    }
                                }
                            } label: {
                                actionButton(action: action)
                                    .contentShape(.rect)
                            }
                            .menuStyle(.button)
                            .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                            .contentShape(Rectangle())
                        } else {
                            actionButton(action: action)
                                .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                                .contentShape(.rect)
                        }
                    }
                }
            case .vertical:
                VStack(alignment: .center, spacing: 10) {
                    ForEach(actions, id: \.self) { action in
                        if action == .menu {
                            Menu {
                                Section {
                                    Button {
                                        showAppleTranslation = true
                                    } label: {
                                        Label("Translate", systemImage: "captions.bubble")
                                    }

                                    if !AccountManager.shared.isCurrentUser(id: postViewModel.post.owner.id) {
                                        Button(role: .destructive) {
                                            Task {
                                                do {
                                                    try await postViewModel.report()
                                                    showPopup(text: "Post was reported.")
                                                } catch let error as PostActionError {
                                                    showPopup(
                                                        text: error.displayMessage,
                                                        icon: error.displayIcon
                                                    )
                                                }
                                            }
                                        } label: {
                                            Label("Report Post", systemImage: "exclamationmark.bubble")
                                        }

                                        Button(role: .destructive) {
                                            Task {
                                                do {
                                                    let isBlocked = try await postViewModel.blockContent()
                                                    if isBlocked {
                                                        showPopup(text: "User's content will be hidden.")
                                                    } else {
                                                        showPopup(text: "User's content will be visible.")
                                                    }
                                                } catch {
                                                    showPopup(
                                                        text: error.userFriendlyDescription
                                                    )
                                                }
                                            }
                                        } label: {
                                            Label("Hide Content from Feed", systemImage: "person.slash.fill")
                                        }
                                    }
                                }
                            } label: {
                                actionButton(action: action)
                            }
                            .menuStyle(.button)
                            .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                            .contentShape(Rectangle())
                        } else {
                            actionButton(action: action)
                                .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                        }
                    }
                }
        }
    }

    private func actionButton(action: PostAction) -> some View {
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
            switch layout {
                case .horizontal:
                    HStack(alignment: .center, spacing: 5) {
                        if action == .menu {
                            action.getIcon(viewModel: postViewModel)
                                .iconSize(width: 16)
                        } else {
                            action.getIcon(viewModel: postViewModel)
                                .iconSize(height: 19)
                        }

                        if let amount = action.getAmount(viewModel: postViewModel) {
                            Text(amount, format: .number.notation(.compactName))
                                .font(.customFont(weight: .regular, size: .body))
                                .lineLimit(1)
                                .contentTransition(.numericText(value: Double(amount)))
                                .foregroundStyle(action.getDefaultColor())
                                .monospacedDigit()
                        }
                    }
                    .frame(height: 32)
                    .contentShape(Rectangle())
                case .vertical:
                    VStack(alignment: .center, spacing: 5) {
                        if action == .menu {
                            action.getIcon(viewModel: postViewModel)
                                .iconSize(width: 16)
                        } else {
                            action.getIcon(viewModel: postViewModel)
                                .iconSize(height: 19)
                        }

                        if let amount = action.getAmount(viewModel: postViewModel) {
                            Text(amount, format: .number.notation(.compactName))
                                .font(.customFont(weight: .regular, size: .body))
                                .lineLimit(1)
                                .contentTransition(.numericText(value: Double(amount)))
                                .foregroundStyle(action.getDefaultColor())
                                .monospacedDigit()
                        }
                    }
                    .ifCondition(action == .menu) {
                        $0.frame(height: 20)
                    }
                    .ifCondition(action != .menu) {
                        $0.frame(height: 40)
                    }
                    .contentShape(Rectangle())
            }
        }
    }

    private func handleAction(action: PostAction) async throws {
        HapticManager.shared.fireHaptic(.notification(.success))
        switch action {
            case .like:
                try await postViewModel.like()
            case .dislike:
                try await postViewModel.dislike()
            case .comment:
                postViewModel.showComments()
            case .views, .menu:
                break
        }
    }
}
