//
//  PostHeaderView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import DesignSystem
import Environment

public struct PostHeaderView: View {
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.isBackgroundWhite) private var isBackgroundWhite

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var postVM: PostViewModel

    public init() {}

    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                router.navigate(to: .accountDetail(id: postVM.post.owner.id))
            } label: {
                ProfileAvatarView(
                    url: postVM.post.owner.imageURL,
                    name: postVM.post.owner.username,
                    config: .post)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 5) {
                        Text(postVM.post.owner.username)
                        //                        .font(.customFont(weight: .boldItalic, size: .footnote))
                            .font(.customFont(weight: .boldItalic, style: .callout))

                        Text("#\(String(postVM.post.owner.slug))")
                            .foregroundStyle(isBackgroundWhite ? Color.textSuggestions : Color.white.opacity(0.5))
                    }

                    Text(postVM.post.formattedCreatedAtLong)
                }
                //            .font(.customFont(weight: .regular, size: .footnoteSmall))
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(isBackgroundWhite ? Color.textActive : Color.white)
                .contentShape(Rectangle())
                .ifCondition(!isBackgroundWhite) {
                    $0.shadow(color: .black, radius: 40, x: 0, y: 0)
                }
            }
            
            Spacer()
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)
            
            if !redactionReasons.contains(.placeholder),
               !accountManager.isCurrentUser(id: postVM.post.owner.id)
            {
                //TODO: exclude logic from Button(just pass correct colors)
                let vm = FollowButtonViewModel(
                    id: postVM.post.owner.id,
                    isFollowing: postVM.post.owner.isFollowing,
                    isFollowed: postVM.post.owner.isFollowed,
                    apiWrapper: postVM.apiManager
                )
                FollowButton(viewModel: vm)
            }
        }
    }
}

#Preview {
    PostHeaderView()
        .padding(20)
        .environment(\.isBackgroundWhite, false)
        .environmentObject(PostViewModel(post: .placeholderText(), apiManager: APIManagerStub()))
}
