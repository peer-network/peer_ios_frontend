//
//  SingleCommentView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment

struct SingleCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.redactionReasons) var reasons
    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var router: Router

    @StateObject private var commentVM: SingleCommentViewModel

    @State private var showPopover = false

    @State private var showSensitiveContentWarning: Bool = false

    init(comment: Comment) {
        _commentVM = .init(wrappedValue: .init(comment: comment))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button {
                dismiss()
                router.navigate(to: .accountDetail(id: commentVM.comment.user.id))
            } label: {
                Text(commentVM.comment.user.visibilityStatus != .hidden ? commentVM.comment.user.username : "hidden_account")
                    .font(.custom(.bodyBoldItalic))
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)
            }

            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 0) {
                    if commentVM.comment.visibilityStatus != .illegal {
                        Group {
                            if let attributedText = commentVM.attributedContent {
                                Text(attributedText)
                            } else {
                                Text(commentVM.comment.content)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        illegalContentView
                    }

                    HStack(spacing: 0) {
                        Text(commentVM.comment.formattedCreatedAt)
                            .font(.custom(.smallLabelRegular))
                            .foregroundStyle(Colors.whiteSecondary)

                        Spacer()
                            .frame(minWidth: 10)
                            .frame(maxWidth: .infinity)
                            .layoutPriority(-1)

                        if !reasons.contains(.placeholder), commentVM.comment.hasActiveReports {
                            IconsNew.flag
                                .iconSize(width: 9)
                                .foregroundStyle(Colors.redAccent)
                                .contentShape(.rect)
                                .onTapGesture {
                                    showPopover = true
                                }
                                .popover(isPresented: $showPopover, arrowEdge: .trailing) {
                                    Text("Reported")
                                        .appFont(.smallLabelRegular)
                                        .foregroundStyle(Colors.redAccent)
                                        .presentationBackground(Colors.inactiveDark)
                                        .presentationCompactAdaptation(.popover)
                                }
                        }

                        if !reasons.contains(.placeholder), AccountManager.shared.isCurrentUser(id: commentVM.comment.user.id), commentVM.comment.isHiddenForUsers {
                            IconsNew.eyeWithSlash
                                .iconSize(width: 9)
                                .foregroundStyle(Colors.whiteSecondary)
                                .padding(.horizontal, 5)

                            Text("Not visible in the feed")
                                .appFont(.smallLabelRegular)
                                .foregroundStyle(Colors.whiteSecondary)
                                .lineLimit(1)
                        }
                    }
                }

                if commentVM.comment.visibilityStatus != .illegal {
                    VStack(spacing: 5) {
                        Button {
                            Task {
                                do {
                                    try await commentVM.likeComment()
                                } catch {
                                    if let error = error as? CommentError {
                                        showPopup(text: error.displayMessage)
                                    } else {
                                        showPopup(
                                            text: error.userFriendlyDescription
                                        )
                                    }
                                }
                            }
                        } label: {
                            Group {
                                if commentVM.isLiked {
                                    Icons.heartFill
                                        .iconSize(height: 15)
                                        .foregroundStyle(Colors.redAccent)
                                } else {
                                    Icons.heart
                                        .iconSize(height: 15)
                                }
                            }
                            .clipShape(Rectangle())
                            .contentShape(.rect)
                        }

                        Button {
                            dismiss()
                            router.navigate(to: .commentLikes(comment: commentVM.comment))
                        } label: {
                            Text("\(commentVM.amountLikes)")
                                .contentShape(.rect)
                        }
                    }
                } else {
                    Spacer()
                        .frame(width: 15)
                }
            }
            .ifCondition(showSensitiveContentWarning) {
                $0
                    .allowsHitTesting(false)
                    .blur(radius: 4)
                    .overlay {
                        sensitiveContentWarningView
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .ignoresSafeArea(.container, edges: .vertical)
                    }
            }
        }
        .font(.custom(.bodyRegular))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .onFirstAppear {
            commentVM.apiService = apiManager.apiService
        }
        .padding(10)
        .contentShape(Rectangle())
        .ifCondition(!showSensitiveContentWarning && commentVM.comment.visibilityStatus != .illegal) {
            $0.contextMenu {
                if !AccountManager.shared.isCurrentUser(id: commentVM.comment.user.id) {
                    Button(role: .destructive) {
                        dismiss()
                        SystemPopupManager.shared.presentPopup(.reportComment) {
                            Task {
                                do {
                                    try await commentVM.report()
                                    showPopup(text: "Comment was reported.")
                                } catch let error as CommentError {
                                    showPopup(
                                        text: error.localizedDescription
                                    )
                                } catch {
                                    showPopup(
                                        text: error.userFriendlyDescription
                                    )
                                }
                            }
                        }
                    } label: {
                        Label("Report Comment", systemImage: "exclamationmark.circle")
                    }
                }
            }
        }
        .padding(-10)
        .onFirstAppear {
            if !reasons.contains(.placeholder), !AccountManager.shared.isCurrentUser(id: commentVM.comment.user.id), commentVM.comment.visibilityStatus == .hidden {
                showSensitiveContentWarning = true
            }
        }
    }

    private var sensitiveContentWarningView: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    IconsNew.eyeWithSlash
                        .iconSize(height: 14)

                    Text("Sensitive content")
                        .appFont(.smallLabelBold)
                }

                Text("This content may be sensitive or abusive.\nDo you want to view it anyway?")
                    .appFont(.smallLabelRegular)
            }
            .foregroundStyle(Colors.whitePrimary)
            .fixedSize(horizontal: false, vertical: true)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            let showButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Show")
            StateButton(config: showButtonConfig) {
                withAnimation {
                    showSensitiveContentWarning = false
                }
            }
            .fixedSize()
        }
        .multilineTextAlignment(.leading)
    }

    private var illegalContentView: some View {
        HStack(spacing: 10) {
            Icons.trashBin
                .iconSize(width: 15)

            Text("This content was removed as illegal")
                .appFont(.smallLabelRegular)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundStyle(Colors.whiteSecondary)
        .padding(.vertical, 1)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}
