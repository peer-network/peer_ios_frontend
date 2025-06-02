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
                    HStack(alignment: .center, spacing: 5) {
                        Text(postVM.post.owner.username)
                            .font(.customFont(weight: .boldItalic, style: .callout))

                        Text("#\(String(postVM.post.owner.slug))")
                            .foregroundStyle(Colors.whiteSecondary)
                    }

                    Text(postVM.post.formattedCreatedAtLong)
                }
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.whitePrimary)
                .contentShape(.rect)
                .shadow(color: .black, radius: 40, x: 0, y: 0)
            }

            Spacer()
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            if showFollowButton,
               !redactionReasons.contains(.placeholder),
               !accountManager.isCurrentUser(id: postVM.post.owner.id)
            {
                //TODO: exclude logic from Button(just pass correct colors)
                let vm = FollowButtonViewModel(
                    id: postVM.post.owner.id,
                    isFollowing: postVM.post.owner.isFollowing,
                    isFollowed: postVM.post.owner.isFollowed
                )
                FollowButton(viewModel: vm)
            }
        }
    }
}
