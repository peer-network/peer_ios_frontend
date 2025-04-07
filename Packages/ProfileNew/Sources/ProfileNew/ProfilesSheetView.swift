//
//  ProfilesSheetView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 10.03.25.
//

import SwiftUI
import Models
import DesignSystem
import Environment

public struct ProfilesSheetView: View {
    @frozen
    public enum SheetType: String {
        case followers = "Followers"
        case following = "Following"
        case friends = "Peers"
    }

    private let type: SheetType
    private let users: [RowUser]

    public init(type: SheetType, users: [RowUser]) {
        self.type = type
        self.users = users
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.bottom, 10)

            Text(type.rawValue)
                .font(.customFont(weight: .regular, size: .body))
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)

            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(users) { user in
                        RowProfileView(user: user)
                    }
                }
                .padding(.horizontal, 10) // to prevent shadows being clipped
                .padding(.vertical, 10) // to prevent shadows being clipped
            }
            .scrollIndicators(.hidden)
            .padding(.top, 5)
            .padding(.horizontal, -10) // to prevent shadows being clipped
            .padding(.vertical, -10) // to prevent shadows being clipped
        }
        .padding(10)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct RowProfileView: View {
    @EnvironmentObject private var router: Router

    let user: RowUser

    var body: some View {
        HStack(spacing: 0) {
            Button {
                router.navigate(to: .accountDetail(id: user.id))
            } label: {
                HStack(spacing: 0) {
                    ProfileAvatarView(url: user.imageURL, name: user.username, config: .rowUser)
                        .padding(.trailing, 10)

                    Text(user.username)
                        .font(.customFont(weight: .boldItalic, style: .callout))
                        .padding(.trailing, 5)

                    Text("#\(String(user.slug))")
                        .opacity(0.5)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.customFont(weight: .regular, style: .footnote))
            .foregroundStyle(Colors.whitePrimary)

            Spacer()

            if !AccountManager.shared.isCurrentUser(id: user.id) {
                FollowButton(
                    id: user.id,
                    isFollowing: user.isFollowing,
                    isFollowed: user.isFollowed
                )
                .environment(\.isBackgroundWhite, false)
            }
        }
    }
}
