//
//  ProfileHeader.swift
//  ProfileNew
//
//  Created by Artem Vasin on 26.05.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

struct ProfileHeader: View {
    @Environment(\.redactionReasons) private var reasons

    @EnvironmentObject private var apiManager: APIServiceManager

    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var router: Router

    let user: User
    let bio: String

    @Binding var showAvatarPicker: Bool

    @State private var showPopover = false
    
    @State private var showSensitiveContentWarning: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                if !reasons.contains(.placeholder), AccountManager.shared.isCurrentUser(id: user.id) {
                    if user.visibilityStatus == .illegal {
                        ownProfileIllegalView
                            .padding(.horizontal, -10)
                    } else if user.isHiddenForUsers {
                        ownProfileHiddenView
                            .padding(.horizontal, -10)
                    }
                }

                if !reasons.contains(.placeholder), !AccountManager.shared.isCurrentUser(id: user.id), user.visibilityStatus == .illegal {
                    otherProfileIllegalView
                        .padding(.horizontal, -10)
                }

                HStack(alignment: .center, spacing: 10) {
                    profileImage

                    VStack(alignment: .leading, spacing: 10) {
                        if user.visibilityStatus == .illegal {
                            Text("removed")
                                .appFont(.bodyBoldItalic)
                                .foregroundStyle(Colors.whitePrimary)
                                .frame(height: 25, alignment: .leading)
                        } else {
                            username
                        }

                        FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
                    }
                }

                if user.visibilityStatus == .illegal {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(Colors.inactiveDark)
                        .frame(height: 21)
                } else if !bio.isEmpty {
                    Text(bio)
                        .appFont(.smallLabelRegular)
                        .foregroundStyle(Colors.whitePrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .ifCondition(showSensitiveContentWarning) {
                $0
                    .allowsHitTesting(false)
                    .blur(radius: 9.55)
                    .overlay {
                        sensitiveContentWarningView
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
            }

            if AccountManager.shared.isCurrentUser(id: user.id) {
                HStack(spacing: 10) {
                    inviteFriendsButton

                    settingsButton

                    moreButton
                }
            } else {
                HStack(spacing: 10) {
                    let vm = FollowButtonViewModel(
                        id: user.id,
                        isFollowing: user.isFollowed,
                        isFollowed: user.isFollowing
                    )
                    FollowButton2(viewModel: vm)

                    moreButton
                }
            }

            RoundedRectangle(cornerRadius: 50)
                .foregroundStyle(Colors.inactiveDark)
                .frame(height: 3)
                .padding(.top, 10)
                .padding(.horizontal, 20)
        }
        .onFirstAppear {
            if !reasons.contains(.placeholder), !AccountManager.shared.isCurrentUser(id: user.id), user.visibilityStatus == .hidden {
                showSensitiveContentWarning = true
            }
        }
    }

    @ViewBuilder
    private var profileImage: some View {
        if accountManager.isCurrentUser(id: user.id) {
            ProfileAvatarView(url: user.imageURL, name: user.username, config: .profile, ignoreCache: true)
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Colors.hashtag)
                        .overlay {
                            Circle()
                                .strokeBorder(Colors.textActive, lineWidth: 1)
                        }
                        .overlay {
                            Icons.pen
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 7)
                        }
                        .offset(y: -5)
                }
                .onTapGesture {
                    showAvatarPicker = true
                }
        } else {
            if user.visibilityStatus == .illegal {
                Circle()
                    .frame(height: 70)
                    .foregroundStyle(Colors.inactiveDark)
                    .overlay {
                        Icons.block
                            .iconSize(height: 48)
                            .foregroundStyle(Colors.whitePrimary)
                    }
            } else {
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .profile, ignoreCache: false)
            }
        }
    }

    private var username: some View {
        HStack(spacing: 0) {
            ViewThatFits {
                HStack(spacing: 0) {
                    usernameText

                    userSlugText
                }

                VStack(alignment: .leading, spacing: 0) {
                    usernameText

                    userSlugText
                }
            }

            if !reasons.contains(.placeholder), user.hasActiveReports {
                Spacer()
                    .frame(minWidth: 10)
                    .layoutPriority(-1)

                IconsNew.flag
                    .iconSize(width: 24)
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
        }
    }

    private var usernameText: some View {
        Text(user.username)
            .appFont(.bodyBoldItalic)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .lineLimit(1)
    }

    private var userSlugText: some View {
        Text("#\(String(user.slug))")
            .appFont(.smallLabelRegular)
            .foregroundStyle(Colors.whiteSecondary)
    }

    @ViewBuilder
    private var inviteFriendsButton: some View {
        let config = StateButtonConfig(buttonSize: .small, buttonType: .secondary, title: "Invite a friend")

        StateButton(config: config) {
            router.navigate(to: RouterDestination.referralProgram)
        }
    }

    @ViewBuilder
    private var settingsButton: some View {
        let config = StateButtonConfig(buttonSize: .small, buttonType: .custom(textColor: Colors.whitePrimary, fillColor: Colors.inactiveDark), title: "Settings", icon: Icons.gear, iconPlacement: .trailing)

        StateButton(config: config) {
            router.navigate(to: RouterDestination.settings)
        }
    }

    private var moreButton: some View {
        Menu {
            if !AccountManager.shared.isCurrentUser(id: user.id) {
                Section {
                    Button(role: .destructive) {
                        Task {
                            let result = await apiManager.apiService.toggleHideUserContent(with: user.id)

                            switch result {
                                case .success(let isNowBlocked):
                                    if isNowBlocked {
                                        showPopup(text: "User was blocked.")
                                    } else {
                                        showPopup(text: "User was unblocked.")
                                    }
                                case .failure(let error):
                                    showPopup(
                                        text: error.userFriendlyDescription
                                    )
                            }
                        }
                    } label: {
                        Label("Toggle User Block", systemImage: "person.slash.fill")
                    }

                    Button(role: .destructive) {
                        SystemPopupManager.shared.presentPopup(.reportUser) {
                            Task {
                                let result = await apiManager.apiService.reportUser(with: user.id)

                                switch result {
                                    case .success():
                                        showPopup(text: "User was reported.")
                                    case .failure(let error):
                                        showPopup(
                                            text: error.userFriendlyDescription
                                        )
                                }
                            }
                        }
                    } label: {
                        Label("Report User", systemImage: "exclamationmark.circle")
                    }
                }
            } else {
                Section {
                    Button {
                        router.navigate(to: RouterDestination.adsHistoryOverview)
                    } label: {
                        Label("My ads", systemImage: "megaphone")
                    }
                }
            }
        } label: {
            Icons.ellipsis
                .iconSize(width: 16)
                .rotationEffect(.degrees(90))
                .foregroundStyle(Colors.whitePrimary)
                .frame(width: 45, height: 45)
                .background(Colors.inactiveDark)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }

    private var ownProfileIllegalView: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(height: 34)
                .foregroundStyle(Colors.redAccent.opacity(0.2))
                .overlay {
                    Icons.trashBin
                        .iconSize(height: 24)
                        .foregroundStyle(Colors.redAccent)
                }

            Text("Your profile data is removed as illegal. No further changes are possible.")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.redAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 20)
        .background {
            Colors.inactiveDark
        }
    }

    private var otherProfileIllegalView: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(height: 34)
                .foregroundStyle(Colors.redAccent.opacity(0.2))
                .overlay {
                    Icons.trashBin
                        .iconSize(height: 24)
                        .foregroundStyle(Colors.redAccent)
                }

            Text("Profile data is removed as illegal")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.redAccent)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 5)
        .padding(.horizontal, 20)
        .background {
            Colors.inactiveDark
        }
    }

    private var ownProfileHiddenView: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(height: 34)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(height: 24)
                        .foregroundStyle(Colors.whitePrimary)
                }

            Text("Profile data is hidden due to report")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whitePrimary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 5)
        .padding(.horizontal, 20)
        .background(Colors.inactiveDark)
    }

    private var sensitiveContentWarningView: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(height: 34)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(height: 24)
                        .foregroundStyle(Colors.whitePrimary)
                }

            VStack(alignment: .leading, spacing: 0) {
                Text("Sensitive content")
                    .appFont(.bodyBold)

                Text("This content may be sensitive or abusive.\nDo you want to view it anyway?")
                    .appFont(.smallLabelRegular)
            }
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)

            let showButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Show")
            StateButton(config: showButtonConfig) {
                withAnimation {
                    showSensitiveContentWarning = false
                }
            }
            .fixedSize()
        }
    }
}
