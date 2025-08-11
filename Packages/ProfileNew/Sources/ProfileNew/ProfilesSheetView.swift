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
import Analytics

public struct ProfilesSheetView<Fetcher>: View where Fetcher: RelationsFetcher {
    @frozen
    public enum SheetType: String {
        case followers = "Followers"
        case following = "Following"
        case friends = "Peers"
    }

    @EnvironmentObject private var apiManager: APIServiceManager
    @StateObject private var fetcher: Fetcher

    private let type: SheetType

    public init(type: SheetType, fetcher: Fetcher) {
        self.type = type
        self._fetcher = StateObject(wrappedValue: fetcher)
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
                .padding(.bottom, 10)

            ScrollView {
                LazyVStack(spacing: 20) {
                    switch fetcher.state {
                        case .error(let error):
                            ErrorView(title: "Error", description: error.userFriendlyDescription) {
                                switch type {
                                    case .followers:
                                        fetcher.fetchFollowers(reset: true)
                                    case .following:
                                        fetcher.fetchFollowings(reset: true)
                                    case .friends:
                                        fetcher.fetchFriends(reset: true)
                                }
                            }
                            .padding(20)

                        case .loading:
                            ForEach(RowUser.placeholders(count: 15)) { user in
                                RowProfileView(user: user)
                                    .allowsHitTesting(false)
                                    .skeleton(isRedacted: true)
                            }

                        case .display(let users, let hasMore):
                            if users.isEmpty {
                                Text("Nothing found...")
                                    .padding(20)
                            } else {
                                ForEach(users) { user in
                                    RowProfileView(user: user) {
                                        let vm = FollowButtonViewModel(
                                            id: user.id,
                                            isFollowing: user.isFollowing,
                                            isFollowed: user.isFollowed
                                        )
//                                        FollowButton(viewModel: vm)
                                        FollowButton2(viewModel: vm)
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .contentShape(Rectangle())
                                }

                                switch hasMore {
                                    case .hasMore:
                                        NextPageView {
                                            switch type {
                                                case .followers:
                                                    fetcher.fetchFollowers(reset: false)
                                                case .following:
                                                    fetcher.fetchFollowings(reset: false)
                                                case .friends:
                                                    fetcher.fetchFriends(reset: false)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    case .none:
                                        EmptyView()
                                }
                            }
                    }
                }
                .padding(.bottom, 34)
            }
            .scrollIndicators(.hidden)
        }
        .padding(10)
        .ignoresSafeArea(.all, edges: .bottom)
        .onFirstAppear {
            switch type {
                case .followers:
                    fetcher.fetchFollowers(reset: true)
                case .following:
                    fetcher.fetchFollowings(reset: true)
                case .friends:
                    fetcher.fetchFriends(reset: true)
            }
        }
        .trackScreen(trackScreen)
    }

    private var trackScreen: AppScreen {
        switch type {
            case .followers:
                return .followersSheet
            case .following:
                return .followingSheet
            case .friends:
                return .friendsSheet
        }
    }
}

//struct RowProfileView<TrailingContent: View>: View {
//    @EnvironmentObject private var router: Router
//    @EnvironmentObject private var apiManager: APIServiceManager
//    @Environment(\.redactionReasons) private var redactionReasons
//
//    private let user: RowUser
//    private let trailingContent: () -> TrailingContent
//
//    private var profileImageIgnoreCache: Bool {
//        AccountManager.shared.isCurrentUser(id: user.id)
//    }
//
//    enum TrailingContent {
//        case unblockButton
//        case followButton
//    }
//
//    init(user: RowUser, @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }) {
//        self.user = user
//        self.trailingContent = trailingContent
//    }
//
//    var body: some View {
//        HStack(spacing: 0) {
//            Button {
//                router.navigate(to: .accountDetail(id: user.id))
//            } label: {
//                HStack(spacing: 0) {
//                    ProfileAvatarView(url: user.imageURL, name: user.username, config: .rowUser, ignoreCache: profileImageIgnoreCache)
//                        .padding(.trailing, 10)
//
//                    Text(user.username)
//                        .font(.customFont(weight: .boldItalic, style: .callout))
//                        .padding(.trailing, 5)
//
//                    Text("#\(String(user.slug))")
//                        .opacity(0.5)
//                }
//                .lineLimit(1)
//                .contentShape(Rectangle())
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .font(.customFont(weight: .regular, style: .footnote))
//            .foregroundStyle(Colors.whitePrimary)
//            .simultaneousGesture(TapGesture())
//
//            Spacer()
//
//            Spacer(minLength: 10)
//
//            if redactionReasons != .placeholder, !AccountManager.shared.isCurrentUser(id: user.id) {
//                trailingContent()
//            }
//        }
//    }
//}
