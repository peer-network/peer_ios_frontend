//
//  ProfileInfoHeaderView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 27.02.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment

struct ProfileInfoHeaderView: View {
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var quickLook: QuickLook
    @EnvironmentObject private var router: Router

    let user: User
    let bio: String

    @Binding var showAvatarPicker: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if accountManager.isCurrentUser(id: user.id) {
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .profile)
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
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .profile)
                    .onTapGesture {
                        let mediaData = MediaData(url: user.imageURL, type: .image)
                        quickLook.prepareFor(selectedMediaAttachment: mediaData, mediaAttachments: [mediaData])
                    }
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Text(user.username)
                        .font(.customFont(weight: .boldItalic, style: .callout))

                    Text("#\(String(user.slug))")
                        .opacity(0.5)
                }

                Spacer()
                    .frame(height: 10)

                Text(bio)
                    .foregroundStyle(Colors.whiteSecondary)
            }

            Spacer()

            if accountManager.isCurrentUser(id: user.id) {
                Button {
                    router.navigate(to: .settings)
                } label: {
                    Icons.gear
                        .iconSize(height: 15)
                }
                .padding(.trailing, 15)
                .frame(maxHeight: .infinity, alignment: .center)
            } else {
                FollowButton(
                    id: user.id,
                    isFollowing: user.isFollowed,
                    isFollowed: user.isFollowing
                )
                .environment(\.isBackgroundWhite, false)
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .foregroundStyle(Colors.whitePrimary)
    }
}

#Preview {
    ZStack {
        Colors.textActive
            .ignoresSafeArea()

        ProfileInfoHeaderView(user: .placeholder(), bio: "Hello, world!", showAvatarPicker: .constant(false))
            .padding(.horizontal, 20)
    }
}
