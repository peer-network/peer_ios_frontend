//
//  SearchView.swift
//  PeerApp
//
//  Created by Artem Vasin on 10.03.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models
import NukeUI

public struct SearchView: View {
    @frozen
    public enum Field {
        case search
    }

    enum SearchType: String {
        case none
        case username = "@username"
        case tag = "#tag"
        case title = "Title"

        var prefix: String {
            switch self {
                case .username:
                    return "@"
                case .tag:
                    return "#"
                default:
                    return ""
            }
        }
    }

    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var router: Router

    @StateObject private var viewModelUsers = SearchViewModelUsers()
    @StateObject private var viewModelTags = SearchViewModelTags()
    @StateObject private var viewModelTitle = SearchViewModelPosts()

    @State private var searchType: SearchType = .none

    @State private var searchText = ""

    @FocusState private var focusedField: Field?

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 1)
    ]

    public init() {}

    public init(searchTag: String) {
        searchType = .tag
        searchText = searchTag
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Search")
        } content: {
            VStack {
                Group {
                    if searchType == .none {
                        HStack(spacing: 10) {
                            typeButton(.username)

                            typeButton(.tag)

                            typeButton(.title)

                            Spacer()

                            Button {
                                // leave empty
                            } label: {
                                Icons.magnifyingglassFill
                                    .iconSize(height: 18)
                                    .foregroundStyle(Colors.whitePrimary)
                                    .padding(.horizontal, 10)
                            }
                        }
                    } else {
                        searchTextFieldView(searchType)
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 10)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                }
                .padding(10)

                ScrollView {
                    Group {
                        switch searchType {
                            case .none:
                                EmptyView()
                            case .username:
                                LazyVStack(spacing: 20) {
                                    ForEach(viewModelUsers.users) { user in
                                        RowProfileSearchView(user: user)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            case .tag:
                                tagsAndPostsView()
                            case .title:
                                postsView()
                        }
                    }
                    .padding(.top, 10)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(Colors.textActive)
        .onChange(of: searchText) {
            switch searchType {
                case .none:
                    break
                case .username:
                    Task {
                        await viewModelUsers.fetchUsers(reset: true, username: searchText)
                    }
                case .tag:
                    if searchText.contains(" ") {
                        searchText.replace(" ", with: "")
                    }
                    Task {
                        await viewModelTags.fetchTags(reset: true, tag: searchText)
                        await viewModelTags.fetchPosts(reset: true, tag: searchText)
                    }
                case .title:
                    Task {
                        await viewModelTitle.fetchPosts(reset: true, title: searchText)
                    }
            }
        }
    }

    @ViewBuilder
    private func postsView() -> some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(viewModelTitle.posts) { post in
                if post.contentType == .image, let imageURL = post.mediaURLs.first {
                    GeometryReader { proxy in
                        LazyImage(
                            request: ImageRequest(
                                url: imageURL,
                                processors: [.resize(size: CGSize(width: 300, height: 300))])
                        ) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: proxy.size.width)
                                    .clipShape(Rectangle())
                            } else {
                                ProgressView()
                                    .frame(width: proxy.size.width, height: proxy.size.width)
                            }
                        }
                        .onTapGesture {
                            router.navigate(to: .postDetailsWithPost(post: post))
                        }
                    }
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                }
            }
        }
    }

    @ViewBuilder
    private func tagsAndPostsView() -> some View {
        TagsView(tags: viewModelTags.tags) { tag in
            Text("#\(tag)")
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.hashtag)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(Colors.whitePrimary))
        } didChangeSelection: { tag in
            searchText = tag ?? ""
            Task {
                await viewModelTags.fetchTags(reset: true, tag: searchText)
                await viewModelTags.fetchPosts(reset: true, tag: searchText)
            }
        }
        .padding(.horizontal, 20)

        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(viewModelTags.posts) { post in
                if post.contentType == .image, let imageURL = post.mediaURLs.first {
                    GeometryReader { proxy in
                        LazyImage(
                            request: ImageRequest(
                                url: imageURL,
                                processors: [.resize(size: CGSize(width: 300, height: 300))])
                        ) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: proxy.size.width)
                                    .clipShape(Rectangle())
                            } else {
                                ProgressView()
                                    .frame(width: proxy.size.width, height: proxy.size.width)
                            }
                        }
                        .onTapGesture {
                            router.navigate(to: .postDetailsWithPost(post: post))
                        }
                    }
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                }
            }
        }
    }

    private func typeButton(_ type: SearchType) -> some View {
        Button {
            searchType = type
            focusedField = .search
        } label: {
            Text(type.rawValue)
                .ifCondition(type == .username) {
                    $0
                        .font(.customFont(weight: .boldItalic, style: .footnote))
                        .foregroundColor(.black)
                }
                .ifCondition(type == .tag) {
                    $0
                        .font(.customFont(weight: .regular, style: .footnote))
                        .foregroundColor(Colors.hashtag)
                }
                .ifCondition(type == .title) {
                    $0
                        .font(.customFont(weight: .regular, style: .footnote))
                        .foregroundColor(Color.black)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.whitePrimary)
                }
        }

    }

    private func searchTextFieldView(_ type: SearchType) -> some View {
        HStack(spacing: 0) {
            Text(type.prefix)
                .ifCondition(type == .username) {
                    $0
                        .font(.customFont(weight: .boldItalic, style: .footnote))
                        .foregroundColor(.white.opacity(0.5))
                }
                .ifCondition(type == .tag) {
                    $0
                        .font(.customFont(weight: .regular, style: .footnote))
                        .foregroundColor(Colors.hashtag)
                }

            TextField(text: $searchText) {
                Group {
                    if type == .title {
                        Text("Title")
                    } else {
                        Text("")
                    }
                }
                .opacity(0.5)
            }
            .focused($focusedField, equals: .search)
            .submitLabel(.search)
            .lineLimit(1)
            .ifCondition(type == .username) {
                $0
                    .font(.customFont(weight: .boldItalic, style: .footnote))
                    .foregroundColor(.white)
            }
            .ifCondition(type == .title) {
                $0
                    .foregroundColor(.white)
            }
            .ifCondition(type == .tag) {
                $0
                    .foregroundColor(Colors.hashtag)
            }

            Spacer()
                .frame(width: 10)

            Button {
                withAnimation {
                    focusedField = nil
                    searchType = .none
                    searchText = ""
                    viewModelUsers.users.removeAll()
                    viewModelTags.posts.removeAll()
                    viewModelTags.tags.removeAll()
                    viewModelTitle.posts.removeAll()
                }
            } label: {
                Icons.arrowsBackRounded
                    .iconSize(height: 21)
                    .foregroundStyle(Colors.whitePrimary)
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .background(Colors.textActive)
    }
}

struct RowProfileSearchView: View {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .font(.customFont(weight: .regular, style: .footnote))
            .foregroundStyle(Colors.whitePrimary)
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(AccountManager.shared)
}
