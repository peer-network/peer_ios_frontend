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
                .padding(.bottom, 5)
            
            switch fetcher.state {
            case .loading:
                Text("Loading...")
                    .padding(20)
                    .frame(maxHeight: .infinity, alignment: .top)
            case .display(let users, let hasMore):
                if users.isEmpty {
                    Text("Nothing found...")
                        .padding(20)
                        .frame(maxHeight: .infinity, alignment: .top)
                } else {
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
                
                switch hasMore {
                    case .hasMore:
                        NextPageView {
                            switch type {
                            case .followers:
                                fetcher.fetchFollowers(reset: false)
                            case .following:
                                fetcher.fetchFollowings(reset: false)
                            case .friends:
                                break
                            }
                        }
                        .padding(.horizontal, 20)
                    case .none:
                        EmptyView()
                }
            case .error(let error):
                VStack(spacing: 20) {
                    Text("An error occurred while loading \(type.rawValue), please try again.")
                        .font(.customFont(weight: .bold, style: .headline))

                    Button("Retry") {
                        switch type {
                        case .followers:
                            fetcher.fetchFollowers(reset: true)
                        case .following:
                            fetcher.fetchFollowings(reset: true)
                        case .friends:
                            break
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(20)
            }
        }
        .padding(10)
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            
            
            switch type {
            case .followers:
                fetcher.fetchFollowers(reset: true)
            case .following:
                fetcher.fetchFollowings(reset: true)
            case .friends:
                break
            }
        }
    }
}

struct RowProfileView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

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
                let vm = FollowButtonViewModel(
                    id: user.id,
                    isFollowing: user.isFollowing,
                    isFollowed: user.isFollowed
                )
                FollowButton(viewModel: vm)
                .environment(\.isBackgroundWhite, false)
            }
        }
    }
}
