//
//  PostActionsView.swift
//  FeedNew
//
//  Created by Артем Васин on 31.01.25.
//

import SwiftUI
import DesignSystem
import Environment

struct PostActionsView: View {
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var postVM: PostViewModel

    var horizontal = true

    @Binding var showAppleTranslation: Bool
    @Binding var showReportAlert: Bool
    @Binding var showBlockAlert: Bool

    private var actions: [PostAction] {
        [.like, .dislike, .comment, .views, .menu]
    }
    
    var body: some View {
        Group {
            if horizontal {
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

                                    if !AccountManager.shared.isCurrentUser(id: postVM.post.owner.id) {
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
                            .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postVM), tintColor: action.tintColor, defaultColor: action.getDefaultColor(isBackgroundWhite: isBackgroundWhite)))
                            .contentShape(Rectangle())
                            .padding(.top, 10)
                        } else {
                            actionButton(action: action)
                        }
                    }
                }
            } else {
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

                                    if !AccountManager.shared.isCurrentUser(id: postVM.post.owner.id) {
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
                            .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postVM), tintColor: action.tintColor, defaultColor: action.getDefaultColor(isBackgroundWhite: isBackgroundWhite)))
                            .contentShape(Rectangle())
                        } else {
                            actionButton(action: action)
                        }
                    }
                }
            }
        }
    }
    
    private func actionButton(action: PostAction) -> some View {
        Button {
            handleAction(action: action)
        } label: {
            if horizontal {
                HStack(alignment: .center, spacing: 5) {
                    if action == .menu {
                        action.getIcon(viewModel: postVM)
                            .iconSize(width: 16)
                    } else {
                        action.getIcon(viewModel: postVM)
                            .iconSize(height: 19)
                    }

                    if let amount = action.getAmount(viewModel: postVM) {
                        Text(amount, format: .number.notation(.compactName))
                            .font(.customFont(weight: .regular, size: .body))
                            .lineLimit(1)
                            .contentTransition(.numericText(value: Double(amount)))
                            .foregroundStyle(action.getDefaultColor(isBackgroundWhite: isBackgroundWhite))
                            .monospacedDigit()
                    }
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            } else {
                VStack(alignment: .center, spacing: 5) {
                    if action == .menu {
                        action.getIcon(viewModel: postVM)
                            .iconSize(width: 16)
                    } else {
                        action.getIcon(viewModel: postVM)
                            .iconSize(height: 19)
                    }

                    if let amount = action.getAmount(viewModel: postVM) {
                        Text(amount, format: .number.notation(.compactName))
                            .font(.customFont(weight: .regular, size: .body))
                            .lineLimit(1)
                            .contentTransition(.numericText(value: Double(amount)))
                            .foregroundStyle(action.getDefaultColor(isBackgroundWhite: isBackgroundWhite))
                            .monospacedDigit()
                    }
                }
                .contentShape(Rectangle())
            }

        }
        .buttonStyle(PostActionButtonStyle(isOn: action.isOn(viewModel: postVM), tintColor: action.tintColor, defaultColor: action.getDefaultColor(isBackgroundWhite: isBackgroundWhite)))
    }
    
    private func handleAction(action: PostAction) {
        Task {
            HapticManager.shared.fireHaptic(.notification(.success))
            do {
                switch action {
                    case .like:
                        try await postVM.toggleLike()
                        showPopup(
                            text: "You used 1 like! Free likes left for today: \(AccountManager.shared.dailyFreeLikes)",
                            icon: Icons.heartFill
                            //.foregroundStyle(Colors.redAccent)
                        )
                    case .dislike:
                        try await postVM.toggleDislike()

                    case .comment:
                        router.presentedSheet = .comments(
                            post: postVM.post,
                            isBackgroundWhite: postVM.post.contentType == .text ? true : false)
                    case .views, .menu:
                        break
                }
            } catch let error as PostActionError {
                showPopup(
                    text: error.displayMessage,
                    icon: error.displayIcon
                )
            }
        }
    }
}

#Preview {
    PostActionsView(showAppleTranslation: .constant(false), showReportAlert: .constant(false), showBlockAlert: .constant(false))
        .padding(20)
        .environment(\.isBackgroundWhite, false)
        .environmentObject(PostViewModel(post: .placeholderText()))
}
