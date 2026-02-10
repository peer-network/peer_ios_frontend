//
//  PostActionsView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem
import Environment

public struct PostActionsView: View {
    @EnvironmentObject private var router: Router

    public enum ActionsLayout { case horizontal, vertical }

    private let actions: [PostAction] = [.like, .dislike, .comment, .views]

    let layout: ActionsLayout

    @ObservedObject var postViewModel: PostViewModel

    public init(layout: ActionsLayout, postViewModel: PostViewModel) {
        self.layout = layout
        self.postViewModel = postViewModel
    }

    public var body: some View {
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
                            .iconSize(height: 24)
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
                                .appFont(.bodyRegular)
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
                            .iconSize(height: 24)
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
                                .appFont(.bodyRegular)
                                .lineLimit(1)
                                .foregroundStyle(action.getDefaultColor())
                                .monospacedDigit()
                                .padding(.bottom, 16)
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



public struct PostActionsSmallView: View {
    @EnvironmentObject private var router: Router

    private let actions: [PostAction] = [.like, .dislike, .comment, .views]

    @ObservedObject var postViewModel: PostViewModel

    public init(postViewModel: PostViewModel) {
        self.postViewModel = postViewModel
    }

    public var body: some View {
            actionButtonsView
    }

    @ViewBuilder
    private var actionButtonsView: some View {
        HStack(spacing: 0) {
            ForEach(actions, id: \.self) { action in
                actionButton(action: action)
                    .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postViewModel), tintColor: action.tintColor, defaultColor: action.getDefaultColor()))
                    .contentShape(.rect)

                if actions.last != action {
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(action: PostAction) -> some View {
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
                    .iconSize(height: 12)
                    .frame(height: 17)
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
                        .font(.custom(.smallLabelRegular))
                        .lineLimit(1)
                        .foregroundStyle(action.getDefaultColor())
                        .monospacedDigit()
                        .frame(height: 17)
                        .padding(.leading, 3.55)
                        .contentShape(.rect)
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
