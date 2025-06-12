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
    
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var quickLook: QuickLook
    @EnvironmentObject private var router: Router

    let user: User
    let bio: String

    @Binding var showAvatarPicker: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 15) {
                profileImage

                VStack(alignment: .leading, spacing: 10) {
                    username

                    FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
                }
            }

            HStack(spacing: 0) {
                Text(bio)
                    .font(.customFont(weight: .regular, style: .footnote))
                    .foregroundStyle(Colors.whiteSecondary)

                Spacer()
                    .frame(minWidth: 20)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                if redactionReasons != .placeholder, !AccountManager.shared.isCurrentUser(id: user.id) {
                    let vm = FollowButtonViewModel(
                        id: user.id,
                        isFollowing: user.isFollowed,
                        isFollowed: user.isFollowing
                    )
                    FollowButton(viewModel: vm)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
    }

    var oldbody: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                profileImage

                Spacer()
                    .frame(width: 15)

                username

                Spacer()

                FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
            }

            HStack(spacing: 10) {
                Text(bio)
                    .font(.customFont(weight: .regular, style: .footnote))
                    .foregroundStyle(Colors.whiteSecondary)

                Spacer()
                    .frame(maxWidth: .infinity)
                    .layoutPriority(-1)

                if redactionReasons != .placeholder, !AccountManager.shared.isCurrentUser(id: user.id) {
                    let vm = FollowButtonViewModel(
                        id: user.id,
                        isFollowing: user.isFollowed,
                        isFollowed: user.isFollowing
                    )
                    FollowButton(viewModel: vm)
                        .environment(\.isBackgroundWhite, false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
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
                .font(.customFont(weight: .boldItalic, style: .callout))
                .foregroundStyle(Colors.whitePrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("#\(String(user.slug))")
                .font(.customFont(weight: .regular, size: .footnote))
                .foregroundStyle(Colors.whiteSecondary)
        }
    }
}
