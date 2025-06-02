//
//  ExploreView.swift
//  Explore
//
//  Created by Artem Vasin on 12.05.25.
//

import SwiftUI
import Environment
import Models
import DesignSystem
import NukeUI
import Analytics

public struct ExploreView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel = ExploreViewModel()

    @State private var searchType: SearchType = .none
    @State private var searchText = ""
    var fixedText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    @State private var initialSearchTag: String?

    private enum Field {
        case search
    }
    @FocusState private var focusedField: Field?

    @State private var task: Task<Void, Never>?

    private var columns: [GridItem] {
        [
            GridItem(.fixed(getRect().width / 3 - 2), spacing: 1),
            GridItem(.fixed(getRect().width / 3 - 2), spacing: 1),
            GridItem(.fixed(getRect().width / 3 - 2), spacing: 1)
            //        GridItem(.adaptive(minimum: 100), spacing: 1)
        ]
    }

    public init() {}

    public init(searchTag: String) {
        self._initialSearchTag = State(initialValue: searchTag)
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Search")
        } content: {
            VStack(spacing: 10) {
                searchBar
                    .padding(.horizontal, 10)

                ScrollView {
                    searchResultsView
                        .padding(.top, 10)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollDisabled(viewModel.isLoading)
            }
            .padding(.top, 10)
        }
        .onChange(of: searchText) {
            guard !fixedText.isEmpty else {
                return
            }
            
            debounceSearch(fixedText)
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService

            if let initialTag = initialSearchTag {
                searchType = .tag
                searchText = initialTag
                initialSearchTag = nil
            } else {
                Task {
                    await viewModel.fetchTrendingPosts(reset: true)
                }
            }
        }
        .trackScreen(AppScreen.search)
    }

    private func debounceSearch(_ text: String) {
        task?.cancel()

        task = Task {
            try? await Task.sleep(for: .seconds(0.5))

            if !Task.isCancelled {
                await performSearch(text)
            }
        }
    }

    private func performSearch(_ text: String) async {
        switch searchType {
            case .none:
                break
            case .username:
                await viewModel.fetchUsers(reset: true, username: text)
            case .tag:
                async let result1: () = viewModel.fetchTags(tag: text)
                async let result2: () = viewModel.fetchPosts(reset: true, tag: text)
                (_, _) = await (result1, result2)
            case .title:
                await viewModel.fetchPosts(reset: true, title: text)
        }
    }

    private func errorView(error: Error, action: (() -> Void)? = nil) -> some View {
        ErrorView(title: "Error", description: error.userFriendlyDescription) {
            action?()
        }
    }
}

// MARK: - Search Bar

extension ExploreView {
    private var searchBar: some View {
        Group {
            switch searchType {
                case .none:
                    defaultSearchBar
                default:
                    searchTextFieldView(searchType)
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Colors.whitePrimary, lineWidth: 1)
        }
    }

    private var defaultSearchBar: some View {
        HStack(spacing: 10) {
            typeButton(.username)

            typeButton(.tag)

            typeButton(.title)

            Spacer()

            Icons.magnifyingglassFill
                .iconSize(height: 18)
                .foregroundStyle(Colors.whitePrimary)
                .padding(.horizontal, 10)
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
                    switch type {
                        case .none:
                            Text("")
                        case .username:
                            Text("username")
                        case .tag:
                            Text("tag")
                        case .title:
                            Text("Title")
                    }
                }
                .opacity(0.5)
            }
            .focused($focusedField, equals: .search)
            .submitLabel(.search)
            .autocorrectionDisabled()
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
                if viewModel.trendindPosts.isEmpty {
                    Task {
                        await viewModel.fetchTrendingPosts(reset: false)
                    }
                }
                viewModel.cleanup()
                focusedField = nil
                searchType = .none
                searchText = ""
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

// MARK: - Results Lists

extension ExploreView {
    @ViewBuilder
    private var searchResultsView: some View {
        switch searchType {
            case .none:
                switch viewModel.state {
                    case .loading:
                        postsGridView(Post.placeholdersImage(count: 30))
                            .allowsHitTesting(false)
                            .skeleton(isRedacted: true)
                    case .display:
                        postsGridView(viewModel.trendindPosts)
                    case .error(let error):
                        errorView(error: error) {
                            Task {
                                await viewModel.fetchTrendingPosts(reset: true)
                            }
                        }
                }
            case .username:
                switch viewModel.state {
                    case .loading:
                        usersListView(RowUser.placeholders(count: 10))
                            .allowsHitTesting(false)
                            .skeleton(isRedacted: true)
                    case .display:
                        usersListView(viewModel.users)
                    case .error(let error):
                        errorView(error: error) {
                            Task {
                                await viewModel.fetchUsers(reset: true, username: fixedText)
                            }
                        }
                }
            case .tag:
                switch viewModel.state {
                    case .loading:
                        postsGridView(Post.placeholdersImage(count: 30))
                            .allowsHitTesting(false)
                            .skeleton(isRedacted: true)
                    case .display:
                        VStack(spacing: 20) {
                            tagsView(viewModel.tags)
                                .padding(.horizontal, 10)

                            postsGridView(viewModel.posts)
                        }
                    case .error(let error):
                        errorView(error: error) {
                            Task {
                                async let result1: () = viewModel.fetchTags(tag: fixedText)
                                async let result2: () = viewModel.fetchPosts(reset: true, tag: fixedText)
                                (_, _) = await (result1, result2)
                            }
                        }
                }
            case .title:
                switch viewModel.state {
                    case .loading:
                        postsGridView(Post.placeholdersImage(count: 30))
                            .allowsHitTesting(false)
                            .skeleton(isRedacted: true)
                    case .display:
                        postsGridView(viewModel.posts)
                    case .error(let error):
                        errorView(error: error) {
                            Task {
                                await viewModel.fetchPosts(reset: true, title: fixedText)
                            }
                        }
                }
        }
    }

    @ViewBuilder
    private func usersListView(_ users: [RowUser]) -> some View {
//        if !fixedText.isEmpty, users.isEmpty {
//            nothingFoundView ??
//        }

        LazyVStack(spacing: 20) {
            ForEach(users) { user in
                Button {
                    router.navigate(to: .accountDetail(id: user.id))
                } label: {
                    RowUserView(user: user)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .padding(.horizontal, 20)
            }

            if !viewModel.users.isEmpty, viewModel.hasMore {
                NextPageView {
                    Task {
                        await viewModel.fetchUsers(reset: false, username: fixedText)
                    }
                }
            }
        }
    }

    private func tagsView(_ tags: [String]) -> some View {
        TagsView(tags: tags) { tag in
            Text("#\(tag)")
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.hashtag)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Colors.whitePrimary)
                }
        } onClick: { tag in
            searchText = tag
        }
    }

    @ViewBuilder
    private func postsGridView(_ posts: [Post]) -> some View {
//        if !fixedText.isEmpty, posts.isEmpty {
//            nothingFoundView ??
//        }

        LazyVStack(spacing: 20) {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(posts) { post in
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
                                    Colors.imageLoadingPlaceholder
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

            if searchType != .none, !viewModel.posts.isEmpty, viewModel.hasMore {
                NextPageView {
                    Task {
                        switch searchType {
                            case .tag:
                                await viewModel.fetchPosts(reset: false, tag: fixedText)
                            case .title:
                                await viewModel.fetchPosts(reset: false, title: fixedText)
                            default:
                                break
                        }
                    }
                }
            }

            if searchType == .none, !viewModel.trendindPosts.isEmpty, viewModel.hasMoreTrendind {
                NextPageView {
                    Task {
                        await viewModel.fetchTrendingPosts(reset: false)
                    }
                }
            }
        }
    }

    private var nothingFoundView: some View {
        Text("Nothing found...")
            .font(.customFont(weight: .regular, style: .body))
            .foregroundStyle(Colors.whitePrimary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
