//
//  FollowersHeader.swift
//  ProfileNew
//
//  Created by Артем Васин on 14.02.25.
//

import SwiftUI
import DesignSystem
import Models
import Environment

struct FollowersHeader: View {
    enum ButtonType: String {
        case posts      = "publications"
        case followers  = "followers"
        case followings = "following"
        case friends    = "peers"
    }

    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var router: Router

    let userId: String
    let postsCount: Int
    let followersCount: Int
    let followingsCount: Int
    let friends: Int

    var body: some View {
        HStack(spacing: 15) {
//            countButton(type: .posts)
//
//            Spacer()

            countButton(type: .followers)

            countButton(type: .followings)

            countButton(type: .friends)
        }
    }

    private func countButton(type: FollowersHeader.ButtonType) -> some View {
        Button {
            switch type {
                case .posts:
                    break
                case .followers:
                    router.presentedSheet = .followers(userId: userId)
                case .followings:
                    router.presentedSheet = .following(userId: userId)
                case .friends:
                    if userId == AccountManager.shared.userId {
                        router.presentedSheet = .friends(userId: userId)
                    } else {
                        break
                    }
            }
        } label: {
            VStack(spacing: 0) {
                Text(typeCount(type), format: .number.notation(.compactName))
                    .bold()
                    .font(.customFont(weight: .regular, size: .body))
                Text(type.rawValue.lowercased())
                    .font(.customFont(weight: .regular, size: .footnote))
            }
            .fixedSize(horizontal: true, vertical: false)
            .contentShape(.rect)
        }
        .foregroundStyle(Colors.whitePrimary)
    }

    private func typeCount(_ type: FollowersHeader.ButtonType) -> Int {
        switch type {
            case .posts:
                postsCount
            case .followers:
                followingsCount
            case .followings:
                followersCount
            case .friends:
                friends
        }
    }
}

#Preview {
    ZStack {
        Colors.textActive
            .ignoresSafeArea()

        FollowersHeader(userId: "", postsCount: 423, followersCount: 244, followingsCount: 1233, friends: 13)
            .padding()
    }
}
