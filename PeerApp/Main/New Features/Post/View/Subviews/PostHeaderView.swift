//
//  PostHeaderView.swift
//  PeerApp
//
//  Created by Artem Vasin on 02.02.26.
//

import SwiftUI
import DesignSystem
import Environment

struct PostHeaderView2: View {
    @Environment(\.redactionReasons) private var redactionReasons

    @EnvironmentObject private var accountManager: AccountManager

    @ObservedObject var viewModel: PostViewModel2

    var body: some View {
        HStack(spacing: 0) {
            Button {
                //
            } label: {
                HStack(spacing: 10) {
                    profileImageView

                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.post.owner.username)
                            .font(.custom(.bodyBoldItalic))

                        Text("#\(String(viewModel.post.owner.slug))")
                            .font(.custom(.smallLabelRegular))
                            .opacity(0.5)
                    }
                    .foregroundStyle(Colors.whitePrimary)
                    .multilineTextAlignment(.leading)
                }
                .contentShape(.rect)
            }
            .ifCondition(viewModel.showHeaderSensitiveWarning) {
                $0
                    .allowsHitTesting(false)
                    .blur(radius: 5)
                    .overlay(alignment: .leading) {
                        Button {
                            withAnimation {
                                viewModel.showHeaderSensitiveWarning = false
                            }
                        } label: {
                            sensitiveContentWarningView
                                .contentShape(.rect)
                        }
                    }
            }

            Spacer(minLength: 20)

            if !redactionReasons.contains(.placeholder),
               !accountManager.isCurrentUser(id: viewModel.post.owner.id),
               !viewModel.post.owner.isFollowing
            {
                let vm = FollowButtonViewModel(
                    id: viewModel.post.owner.id,
                    isFollowing: viewModel.post.owner.isFollowed,
                    isFollowed: viewModel.post.owner.isFollowing
                )
                FollowButton2(viewModel: vm)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.trailing, 10)
            }

            if viewModel.post.advertisement != nil {
                PinIndicatorView2()
                    .padding(.trailing, 10)
            }

            if !viewModel.showIllegalBlur {
                Button {
                    //
                } label: {
                    Icons.ellipsis
                        .iconSize(width: 16)
                        .padding(.horizontal, 4)
                        .frame(height: 24)
                        .contentShape(.rect)
                }
            }
        }
    }

    @ViewBuilder
    private var profileImageView: some View {
        if viewModel.post.owner.visibilityStatus == .illegal {
            Circle()
                .foregroundStyle(Colors.inactiveDark)
                .frame(height: 37)
        } else {
            ProfileAvatarView(
                url: viewModel.post.owner.imageURL,
                name: viewModel.post.owner.username,
                config: .postHeader,
                ignoreCache: false
            )
        }
    }

    @ViewBuilder
    private var sensitiveContentWarningView: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(height: 34)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(width: 20)
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
