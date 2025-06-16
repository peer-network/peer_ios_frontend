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
    @Binding var showReportAlert: Bool

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
                                            showReportAlert = true
                                        } label: {
                                            Label("Report Post", systemImage: "exclamationmark.bubble")
                                        }
                                    }

                                    //                                    if !AccountManager.shared.isCurrentUser(id: postVM.post.owner.id) {
                                    //                                        Button(role: .destructive) {
                                    //                                            showBlockAlert = true
                                    //                                        } label: {
                                    //                                            Label("Block User", systemImage: "person.crop.circle.badge.exclamationmark")
                                    //                                        }
                                    //                                    }
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
                                            showReportAlert = true
                                        } label: {
                                            Label("Report Post", systemImage: "exclamationmark.bubble")
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
