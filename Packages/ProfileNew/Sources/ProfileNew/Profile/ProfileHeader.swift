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
    @Environment(\.redactionReasons) private var redactionReasons

    @EnvironmentObject private var apiManager: APIServiceManager

    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var quickLook: QuickLook
    @EnvironmentObject private var router: Router

    let user: User
    let bio: String

    @Binding var showAvatarPicker: Bool

    var body: some View {
        VStack(spacing: 15) {
            HStack(alignment: .center, spacing: 15) {
                profileImage

                VStack(alignment: .leading, spacing: 10) {
                    username

                    FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
                }
            }

            if !bio.isEmpty {
                Text(bio)
                    .font(.custom(.smallLabelRegular))
                    .foregroundStyle(Colors.whitePrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
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
            ProfileAvatarView(url: user.imageURL, name: user.username, config: .profile, ignoreCache: false)
                .onTapGesture {
                    let mediaData = MediaData(url: user.imageURL, type: .image)
                    quickLook.prepareFor(selectedMediaAttachment: mediaData, mediaAttachments: [mediaData])
                }
        }
    }

    private var username: some View {
        HStack(alignment: .center, spacing: 5) {
            Text(user.username)
                .font(.custom(.bodyBoldItalic))
                .foregroundStyle(Colors.whitePrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)

            Text("#\(String(user.slug))")
                .font(.custom(.smallLabelRegular))
                .foregroundStyle(Colors.whiteSecondary)
        }
    }

    @ViewBuilder
    private var inviteFriendsButton: some View {
        let config = StateButtonConfig(buttonSize: .small, buttonType: .secondary, title: "Invite a friend")

        StateButton(config: config) {
            router.navigate(to: .referralProgram)
        }
    }

    @ViewBuilder
    private var settingsButton: some View {
        let config = StateButtonConfig(buttonSize: .small, buttonType: .custom(textColor: Colors.whitePrimary, fillColor: Colors.inactiveDark), title: "Settings", icon: Icons.gear, iconPlacement: .trailing)

        StateButton(config: config) {
            router.navigate(to: .settings)
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
                    } label: {
                        Label("Report User", systemImage: "exclamationmark.circle")
                    }
                }
            } else {
                Section {
                    Button {
                        //
                    } label: {
                        Text("My ads")
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
}
