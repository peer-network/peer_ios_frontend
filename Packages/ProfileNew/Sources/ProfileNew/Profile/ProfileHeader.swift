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
    @EnvironmentObject private var quickLook: QuickLook
    @EnvironmentObject private var router: Router

    let user: User
    let bio: String

    @Binding var showAvatarPicker: Bool

    @State private var showPopover = false
    
    @State private var showSensitiveContentWarning: Bool = false

    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 15) {
                if !reasons.contains(.placeholder), AccountManager.shared.isCurrentUser(id: user.id) {
                    if user.visibilityStatus == .illegal {
                        ownProfileIllegalView
                    } else if user.isHiddenForUsers {
                        ownProfileHiddenView
                            .padding(.horizontal, -20)
                    }
                }

                HStack(alignment: .center, spacing: 15) {
                    profileImage

                    VStack(alignment: .leading, spacing: 10) {
                        if !AccountManager.shared.isCurrentUser(id: user.id), user.visibilityStatus == .illegal {
                            RoundedRectangle(cornerRadius: 24)
                                .frame(width: 138, height: 21)
                                .foregroundStyle(Colors.inactiveDark)
                        } else {
                            username
                        }

                        FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
                    }
                }

                if !bio.isEmpty {
                    if AccountManager.shared.isCurrentUser(id: user.id) || user.visibilityStatus != .illegal {
                        Text(bio)
                            .font(.custom(.smallLabelRegular))
                            .foregroundStyle(Colors.whitePrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                }

                if !reasons.contains(.placeholder), !AccountManager.shared.isCurrentUser(id: user.id), user.visibilityStatus == .illegal {
                    otherProfileIllegalView
                }
            }
            .ifCondition(showSensitiveContentWarning) {
                $0
                    .allowsHitTesting(false)
                    .blur(radius: 5)
                    .overlay {
                        sensitiveContentWarningView
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
            }

            if AccountManager.shared.isCurrentUser(id: user.id) {
                HStack(spacing: 15) {
                    inviteFriendsButton

                    settingsButton

                    moreButton
                }
            } else {
                HStack(spacing: 15) {
                    let vm = FollowButtonViewModel(
                        id: user.id,
                        isFollowing: user.isFollowed,
                        isFollowed: user.isFollowing
                    )
                    FollowButton2(viewModel: vm)

                    moreButton
                }
            }
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
                    .frame(height: 68)
                    .foregroundStyle(Colors.inactiveDark)
            } else {
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .profile, ignoreCache: false)
                    .onTapGesture {
                        let mediaData = MediaData(url: user.imageURL, type: .image)
                        quickLook.prepareFor(selectedMediaAttachment: mediaData, mediaAttachments: [mediaData])
                    }
            }
        }
    }

    private var username: some View {
        HStack(spacing: 0) {
            Text(user.username)
                .font(.custom(.bodyBoldItalic))
                .foregroundStyle(Colors.whitePrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 5)

            Text("#\(String(user.slug))")
                .font(.custom(.smallLabelRegular))
                .foregroundStyle(Colors.whiteSecondary)

            if !reasons.contains(.placeholder), user.hasActiveReports {
                Spacer()
                    .frame(minWidth: 5)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                IconsNew.flag
                    .iconSize(width: 13)
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
                    .fixedSize()
            }
        }
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
        HStack(spacing: 15) {
            Icons.trashBin
                .iconSize(width: 15)

            Text("**Your profile data is removed as illegal.** All changes you make will not be visible for others")
                .appFont(.smallLabelRegular)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Colors.redAccent)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var otherProfileIllegalView: some View {
        HStack(spacing: 15) {
            Icons.trashBin
                .iconSize(width: 15)

            Text("Profile data is removed as illegal")
                .appFont(.bodyBold)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundStyle(Colors.whitePrimary)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }

    private var ownProfileHiddenView: some View {
        HStack(spacing: 5) {
            IconsNew.eyeWithSlash
                .iconSize(width: 13)

            Text("Profile data is hidden due to reports")
                .appFont(.smallLabelRegular)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundStyle(Colors.whiteSecondary)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Colors.inactiveDark)
    }

    private var sensitiveContentWarningView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Group {
                    Circle()
                        .frame(height: 30)
                        .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                        .overlay {
                            IconsNew.eyeWithSlash
                                .iconSize(height: 16.2)
                                .foregroundStyle(Colors.whitePrimary)
                        }
                        .padding(.trailing, 5)

                    Text("Sensitive content")
                        .appFont(.bodyBold)
                        .foregroundStyle(Colors.whitePrimary)
                }
                .fixedSize(horizontal: true, vertical: false)

                Spacer()
                    .frame(minWidth: 10)
                    .frame(maxWidth: .infinity)

                let showButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Show")
                StateButton(config: showButtonConfig) {
                    withAnimation {
                        showSensitiveContentWarning = false
                    }
                }
                .fixedSize()
            }

            Text("This content may be sensitive or abusive.\nDo you want to view it anyway?")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whitePrimary)
                .fixedSize()
        }
        .multilineTextAlignment(.leading)
    }
}
