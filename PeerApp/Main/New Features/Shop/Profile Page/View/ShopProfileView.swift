//
//  ShopProfileView.swift
//  PeerApp
//
//  Created by Artem Vasin on 05.01.26.
//

import SwiftUI
import DesignSystem
import ProfileNew
import Models
import Environment

struct ShopProfileView: View {
    @Environment(\.selectedTabScrollToTop) private var selectedTabScrollToTop

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var headerVM: ProfileViewModel
    @StateObject private var catalogVM: ShopCatalogViewModel

    @State private var layout = ShopItemsDisplayType.list

    @State private var showFullHeader = true
    private let fullHeaderHeight: CGFloat = 145
    private let collapsedHeaderHeight: CGFloat = 65
    private let tabControllerHeight: CGFloat = 34

    @State private var followButtonVM: FollowButtonViewModel?

    @Namespace private var animation

    init(shopUserId: String) {
        _headerVM = .init(wrappedValue: .init(userId: shopUserId))
        _catalogVM = .init(
            wrappedValue: .init(
                shopUserId: shopUserId,
                repo: FirestoreShopItemRepository()
            )
        )
    }

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            content
        }
        .onFirstAppear {
            headerVM.apiService = apiManager.apiService
            catalogVM.apiService = apiManager.apiService

            Task {
                await headerVM.fetchUser()
                await headerVM.fetchBio()

                guard let user = headerVM.user else { return }
                followButtonVM = FollowButtonViewModel(
                    id: user.id,
                    isFollowing: user.isFollowed,
                    isFollowed: user.isFollowing
                )

                catalogVM.fetchNextPage(reset: true)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let user = headerVM.user {
            ZStack(alignment: .top) {
                if #available(iOS 18.0, *) {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            ScrollToView()
                            VStack(spacing: 0) {
                                Color.clear
                                    .frame(height: fullHeaderHeight + tabControllerHeight + 10)

                                shopItemsView
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .onScrollGeometryChange(for: CGFloat.self) { geo in
                            geo.contentOffset.y
                        } action: { _, newValue in
                            updateHeaderState(contentOffsetY: newValue)
                        }
                        .onChange(of: selectedTabScrollToTop) {
                            if selectedTabScrollToTop == 3, router.path.isEmpty {
                                withAnimation {
                                    scrollProxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                                }
                            }
                        }
                    }
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            ScrollToView()
                            VStack(spacing: 0) {
                                ScrollViewOffsetObserver { y in
                                    updateHeaderState(contentOffsetY: y)
                                }
                                .frame(height: 1)          // non-zero so it isn't optimized away
                                .opacity(0.01)             // effectively invisible, but still lays out
                                .allowsHitTesting(false)

                                Color.clear
                                    .frame(height: fullHeaderHeight + tabControllerHeight + 10)

                                shopItemsView
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                            }
                        }
                        .onChange(of: selectedTabScrollToTop) {
                            if selectedTabScrollToTop == 3, router.path.isEmpty {
                                withAnimation {
                                    scrollProxy.scrollTo(ScrollToView.Constants.scrollToTop, anchor: .top)
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 10) {
                    if showFullHeader {
                        headerView(user: user)
                            .padding(.horizontal, 20)
                    } else {
                        collapsedHeaderView(user: user)
                            .padding(.horizontal, 20)
                    }

                    ShopTabControllerView(type: $layout)
                }
                .background(Colors.blackDark)
            }
        } else {
            ProgressView()
                .controlSize(.large)
                .padding(.top, 100)
        }
    }

    private func updateHeaderState(contentOffsetY: CGFloat) {
        let threshold = (fullHeaderHeight - collapsedHeaderHeight)
        let shouldShowFull = contentOffsetY <= threshold

        guard shouldShowFull != showFullHeader else { return }

        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.12)) {
            showFullHeader = shouldShowFull
        }
    }

    private func headerView(user: User) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 10) {
                ProfileAvatarView(url: user.imageURL, name: user.username, config: .shop, ignoreCache: false)
                    .matchedGeometryEffect(id: "Avatar", in: animation)

                VStack(alignment: .leading, spacing: 0) {
                    Text(user.username)
                        .appFont(.bodyBold)
                        .matchedGeometryEffect(id: "Username", in: animation)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(headerVM.fetchedBio)
                        .appFont(.smallLabelRegular)
                }
                .multilineTextAlignment(.leading)
                .foregroundStyle(Colors.whitePrimary)
            }

            HStack(spacing: 10) {
                if let vm = followButtonVM {
                    FollowButton2(viewModel: vm)
                        .matchedGeometryEffect(id: "FollowButton", in: animation)
                } else {
                    FollowButton2(viewModel: .init(id: "placeholder", isFollowing: false, isFollowed: false))
                        .skeleton(isRedacted: true)
                        .allowsHitTesting(false)
                        .matchedGeometryEffect(id: "FollowButton", in: animation)
                }

                let questionMarkBtnCfg = StateButtonConfig(buttonSize: .small, buttonType: .custom(textColor: Colors.blackDark, fillColor: Colors.whitePrimary), title: "", icon: IconsNew.questionmarkCircle, iconPlacement: .trailing)
                StateButton(config: questionMarkBtnCfg) {
                    SystemPopupManager.shared.presentCustomPopup {
                        ShopFAQView {
                            SystemPopupManager.shared.dismiss()
                        }
                    }
                }
                .fixedSize()
            }
        }
        .padding(10)
        .frame(height: fullHeaderHeight)
        .background(Color(red: 0, green: 0.41, blue: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func collapsedHeaderView(user: User) -> some View {
        HStack(alignment: .center, spacing: 10) {
            ProfileAvatarView(url: user.imageURL, name: user.username, config: .shopSmall, ignoreCache: false)
                .matchedGeometryEffect(id: "Avatar", in: animation)

            Text(user.username)
                .appFont(.bodyBold)
                .foregroundStyle(Colors.whitePrimary)
                .matchedGeometryEffect(id: "Username", in: animation)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let vm = followButtonVM {
                FollowButton2(viewModel: vm)
                    .fixedSize()
                    .matchedGeometryEffect(id: "FollowButton", in: animation)
            }

        }
        .padding(10)
        .frame(height: collapsedHeaderHeight)
        .background(Color(red: 0, green: 0.41, blue: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    @ViewBuilder
    private var shopItemsView: some View {
        switch catalogVM.state {
            case .loading:
                skeletonGridOrList
            case .error(let msg):
                ErrorView(title: "Error", description: msg) {
                    catalogVM.fetchNextPage(reset: true)
                }
            case .ready:
                gridOrList
        }
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    }

    @ViewBuilder
    private var gridOrList: some View {
        switch layout {
        case .grid:
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(catalogVM.listings) { listing in
                    ShopItemTileView(shopPost: listing, displayType: .grid)
                        .onFirstAppear { catalogVM.loadMoreIfNeeded(currentListingID: listing.id) }
                }
            }

        case .list:
            LazyVStack(spacing: 10) {
                ForEach(catalogVM.listings) { listing in
                    ShopItemTileView(shopPost: listing, displayType: .list)
                        .onFirstAppear { catalogVM.loadMoreIfNeeded(currentListingID: listing.id) }
                }
            }
        }
    }

    private var skeletonGridOrList: some View {
        let placeholders = Array(0..<10)
        return Group {
            switch layout {
                case .grid:
                    let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(placeholders, id: \.self) { _ in
                            Rectangle().fill(Colors.inactiveDark).aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .skeleton(isRedacted: true)
                        }
                    }
                case .list:
                    LazyVStack(spacing: 10) {
                        ForEach(placeholders, id: \.self) { _ in
                            Rectangle().fill(Colors.inactiveDark).frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .skeleton(isRedacted: true)
                        }
                    }
            }
        }
    }
}

private struct ScrollViewOffsetObserver: UIViewRepresentable {
    let onChange: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onChange: onChange) }

    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onChange = onChange

        // Attach after it's actually in the hierarchy
        DispatchQueue.main.async {
            context.coordinator.attachIfNeeded(from: uiView)
        }
    }

    final class Coordinator: NSObject {
        var onChange: (CGFloat) -> Void
        private weak var scrollView: UIScrollView?
        private var observation: NSKeyValueObservation?

        init(onChange: @escaping (CGFloat) -> Void) {
            self.onChange = onChange
        }

        func attachIfNeeded(from view: UIView) {
            guard scrollView == nil else { return }

            // Walk up to find the nearest UIScrollView
            var v: UIView? = view
            while let current = v {
                if let sv = current as? UIScrollView {
                    scrollView = sv

                    observation = sv.observe(\.contentOffset, options: [.initial, .new]) { [weak self] sv, _ in
                        guard let self else { return }
                        let normalizedY = sv.contentOffset.y + sv.adjustedContentInset.top
                        self.onChange(max(0, normalizedY))
                    }
                    return
                }
                v = current.superview
            }
        }

        deinit { observation?.invalidate() }
    }
}
