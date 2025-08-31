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
    @EnvironmentObject private var accountManager: AccountManager

    @ObservedObject var postVM: PostViewModel
    
    @Binding var showAppleTranslation: Bool
    let showFollowButton: Bool

    var profileImageIgnoreCache: Bool {
        AccountManager.shared.isCurrentUser(id: postVM.post.owner.id)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                router.navigate(to: .accountDetail(id: postVM.post.owner.id))
            } label: {
                ProfileAvatarView(
                    url: postVM.post.owner.imageURL,
                    name: postVM.post.owner.username,
                    config: .post,
                    ignoreCache: profileImageIgnoreCache
                )

                VStack(alignment: .leading, spacing: 0) {
                    Text(postVM.post.owner.username)
                        .font(.customFont(weight: .boldItalic, style: .callout))

                    Text("#\(String(postVM.post.owner.slug))")
                        .foregroundStyle(Colors.whiteSecondary)
                }
                .font(.customFont(weight: .regular, style: .footnote))
                .lineLimit(1)
//                .minimumScaleFactor(0.5)
                .foregroundStyle(Colors.whitePrimary)
                .contentShape(.rect)
            }

            Spacer(minLength: 20)

            if showFollowButton,
               !redactionReasons.contains(.placeholder),
               !accountManager.isCurrentUser(id: postVM.post.owner.id),
               !postVM.post.owner.isFollowed
            {
                //TODO: exclude logic from Button(just pass correct colors)
                let vm = FollowButtonViewModel(
                    id: postVM.post.owner.id,
                    isFollowing: postVM.post.owner.isFollowing,
                    isFollowed: postVM.post.owner.isFollowed
                )
                FollowButton2(viewModel: vm)
                    .fixedSize(horizontal: true, vertical: false)
            }

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
                }

                if !AccountManager.shared.isCurrentUser(id: postVM.post.owner.id) {
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
                            Task {
                                do {
                                    try await postVM.report()
                                    showPopup(text: "Post was reported.")
                                } catch let error as PostActionError {
                                    showPopup(
                                        text: error.displayMessage,
                                        icon: error.displayIcon
                                    )
                                }
                            }
                        } label: {
                            Label("Report Post", systemImage: "exclamationmark.circle")
                        }
                    }
                }
            } label: {
                Icons.ellipsis
                    .iconSize(width: 16)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .contentShape(.rect)
            }
            .menuStyle(.button)
            .buttonStyle(PostActionButtonStyle(isOn: false, tintColor: nil, defaultColor: Colors.whitePrimary))
            .contentShape(.rect)
        }
    }
}
