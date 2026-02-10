//
//  PostHeaderView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem
import Environment

struct PostHeaderView: View {
    @Environment(\.redactionReasons) private var redactionReasons

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var flows: PromotePostFlowStore

    @ObservedObject var postVM: PostViewModel

    @Binding var showAppleTranslation: Bool
    let showFollowButton: Bool

    var profileImageIgnoreCache: Bool {
        AccountManager.shared.isCurrentUser(id: postVM.post.owner.id)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                router.navigate(to: RouterDestination.accountDetail(id: postVM.post.owner.id))
            } label: {
                HStack(alignment: .center, spacing: 0) {
                    if postVM.post.owner.visibilityStatus == .illegal {
                        Circle()
                            .foregroundStyle(Colors.inactiveDark)
                            .frame(height: 37)
                            .overlay {
                                Icons.block
                                    .iconSize(height: 24)
                                    .foregroundStyle(Colors.whitePrimary)
                            }
                    } else {
                        ProfileAvatarView(
                            url: postVM.post.owner.imageURL,
                            name: postVM.post.owner.username,
                            config: .post,
                            ignoreCache: profileImageIgnoreCache
                        )
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        usernameTextView(postVM.post.owner.visibilityStatus == .illegal ? "removed" : postVM.post.owner.username)

                        userSlugTextView
                    }
                    .padding(.leading, 10)
                }
                .contentShape(.rect)
            }
            .ifCondition(postVM.showHeaderSensitiveWarning) {
                $0
                    .allowsHitTesting(false)
                    .blur(radius: 5)
                    .overlay(alignment: .leading) {
                        Button {
                            withAnimation {
                                postVM.showHeaderSensitiveWarning = false
                            }
                        } label: {
                            sensitiveContentWarningForPostHeaderView
                                .contentShape(.rect)
                        }
                    }
            }

            Spacer()
                .frame(minWidth: 10)
                .layoutPriority(-1)

            if showFollowButton,
               !redactionReasons.contains(.placeholder),
               !accountManager.isCurrentUser(id: postVM.post.owner.id),
               !postVM.post.owner.isFollowing
            {
                let vm = FollowButtonViewModel(
                    id: postVM.post.owner.id,
                    isFollowing: postVM.post.owner.isFollowed,
                    isFollowed: postVM.post.owner.isFollowing
                )
                FollowButton2(viewModel: vm)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.trailing, 10)
            }

            if postVM.post.advertisement != nil {
                PinIndicatorView()
                    .padding(.trailing, 10)
            }

            if !postVM.showIllegalBlur {
                Menu {
                    Section {
                        Button {
                            postVM.showShareSheet = true
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            showAppleTranslation = true
                        } label: {
                            Label("Translate", systemImage: "captions.bubble")
                        }

                        if postVM.post.owner.id == Env.shopUserId {
                            Button {
                                router.navigate(to: ShopRoute.purchaseWithPost(post: postVM.post))
                            } label: {
                                Label("To the item", systemImage: "arrow.up.forward")
                            }
                        }

                        if AccountManager.shared.isCurrentUser(id: postVM.post.owner.id), postVM.post.advertisement == nil {
                            Button {
                                if postVM.post.isHiddenForUsers {
                                    SystemPopupManager.shared.presentPopup(.postPromotionHidden) {
                                        let flowID = flows.startFlow(
                                            post: postVM.post,
                                            apiService: apiManager.apiService,
                                            tokenomics: appState.getConstants()!.data.tokenomics,
                                            popupManager: SystemPopupManager.shared,
                                            onGoToProfile: {
                                                router.navigate(to: RouterDestination.accountDetail(id: postVM.post.owner.id))
                                            },
                                            onGoToPost: {
                                                router.navigate(to: RouterDestination.postDetailsWithPostId(id: postVM.post.id))
                                            },
                                            onFinish: { [weak router] in
                                                // Dismiss entire flow; we pop to wherever we want.
                                            }
                                        )
                                        router.navigate(to: RouterDestination.promotePost(flowID: flowID, step: .config))
                                    }
                                } else if postVM.post.hasActiveReports {
                                    SystemPopupManager.shared.presentPopup(.postPromotionReview) {
                                        let flowID = flows.startFlow(
                                            post: postVM.post,
                                            apiService: apiManager.apiService,
                                            tokenomics: appState.getConstants()!.data.tokenomics,
                                            popupManager: SystemPopupManager.shared,
                                            onGoToProfile: {
                                                router.navigate(to: RouterDestination.accountDetail(id: postVM.post.owner.id))
                                            },
                                            onGoToPost: {
                                                router.navigate(to: RouterDestination.postDetailsWithPostId(id: postVM.post.id))
                                            },
                                            onFinish: { [weak router] in
                                                // Dismiss entire flow; we pop to wherever we want.
                                            }
                                        )
                                        router.navigate(to: RouterDestination.promotePost(flowID: flowID, step: .config))
                                    }
                                } else {
                                    SystemPopupManager.shared.presentPopup(.postPromotion) {
                                        let flowID = flows.startFlow(
                                            post: postVM.post,
                                            apiService: apiManager.apiService,
                                            tokenomics: appState.getConstants()!.data.tokenomics,
                                            popupManager: SystemPopupManager.shared,
                                            onGoToProfile: {
                                                router.navigate(to: RouterDestination.accountDetail(id: postVM.post.owner.id))
                                            },
                                            onGoToPost: {
                                                router.navigate(to: RouterDestination.postDetailsWithPostId(id: postVM.post.id))
                                            },
                                            onFinish: { [weak router] in
                                                // Dismiss entire flow; we pop to wherever we want.
                                            }
                                        )
                                        router.navigate(to: RouterDestination.promotePost(flowID: flowID, step: .config))
                                    }
                                }
                            } label: {
                                Label("Boost post", systemImage: "megaphone")
                            }
                        }
                    }

                    if !AccountManager.shared.isCurrentUser(id: postVM.post.owner.id), postVM.post.owner.id != Env.shopUserId {
                        Section {
                            Button(role: .destructive) {
                                Task {
                                    do {
                                        let isBlocked = try await postVM.blockContent()
                                        if isBlocked {
                                            showPopup(text: "User was blocked.")
                                        } else {
                                            showPopup(text: "User was unblocked.")
                                        }
                                    } catch {
                                        showPopup(
                                            text: error.userFriendlyDescription
                                        )
                                    }
                                }
                            } label: {
                                Label("Toggle User Block", systemImage: "person.slash.fill")
                            }

                            Button(role: .destructive) {
                                SystemPopupManager.shared.presentPopup(.reportPost) {
                                    Task {
                                        do {
                                            try await postVM.report()
                                            showPopup(text: "Post was reported.")
                                        } catch let error as PostActionError {
                                            showPopup(
                                                text: error.displayMessage,
                                                icon: error.displayIcon
                                            )
                                        } catch {
                                            showPopup(
                                                text: error.userFriendlyDescription
                                            )
                                        }
                                    }
                                }
                            } label: {
                                Label("Report Post", systemImage: "exclamationmark.circle")
                            }
                        }
                    }
                } label: {
                    Icons.ellipsis
                        .iconSize(width: 24)
                        .contentShape(.rect)
                }
                .menuStyle(.button)
                .buttonStyle(PostActionButtonStyle(isOn: false, tintColor: nil, defaultColor: Colors.whitePrimary))
            }
        }
        .padding(10)
    }

    private func usernameTextView(_ username: String) -> some View {
        Text(username)
            .appFont(.bodyBoldItalic)
            .foregroundStyle(Colors.whitePrimary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    private var userSlugTextView: some View {
        Text("#\(String(postVM.post.owner.slug))")
            .appFont(.smallLabelRegular)
            .foregroundStyle(Colors.whiteSecondary)
    }

    private var sensitiveContentWarningForPostHeaderView: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(height: 37)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(height: 24)
                        .foregroundStyle(Colors.whitePrimary)
                }

            VStack(alignment: .leading, spacing: 0) {
                Text("Sensitive content")
                    .appFont(.smallLabelBold)

                Text("Click to see")
                    .appFont(.smallLabelRegular)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .fixedSize(horizontal: true, vertical: false)
    }
}

private struct PinIndicatorView: View {
    var body: some View {
        Circle()
            .frame(height: 37)
            .foregroundStyle(Colors.version)
            .overlay {
                Icons.pin
                    .iconSize(height: 15.61)
                    .foregroundStyle(Colors.whitePrimary)
            }
    }
}

enum Env {
    static var shopUserId: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SHOP_USER_ID") as? String,
              !value.isEmpty
        else {
            assertionFailure("Missing SHOP_USER_ID in host app Info.plist")
            return ""
        }
        return value
    }
}
