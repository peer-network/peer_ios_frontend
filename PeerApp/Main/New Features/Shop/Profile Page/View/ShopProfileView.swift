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
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var headerVM: ProfileViewModel
    @StateObject private var catalogVM: ShopCatalogViewModel

    @State private var layout = ShopItemsDisplayType.list

    @State private var showFullHeader = true
    private let fullHeaderHeight: CGFloat = 145
    private let collapsedHeaderHeight: CGFloat = 65
    private let tabControllerHeight: CGFloat = 34

    @State private var offsetY17: CGFloat = 0

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
                    ScrollView {
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
                } else {
                    OffsetTrackingScrollView(offsetY: $offsetY17, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: fullHeaderHeight + tabControllerHeight + 10)

                            shopItemsView
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                        }
                    }
                    .onChange(of: offsetY17) {
                        updateHeaderState(contentOffsetY: offsetY17)
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
                        .lineLimit(1)
                        .matchedGeometryEffect(id: "Username", in: animation)

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
                .lineLimit(1)
                .foregroundStyle(Colors.whitePrimary)
                .matchedGeometryEffect(id: "Username", in: animation)
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

// MARK: - iOS 17 offset tracking scroll view (stable)

private struct OffsetTrackingScrollView<Content: View>: UIViewRepresentable {
    @Binding var offsetY: CGFloat
    let showsIndicators: Bool
    let content: Content

    init(offsetY: Binding<CGFloat>, showsIndicators: Bool, @ViewBuilder content: () -> Content) {
        _offsetY = offsetY
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(offsetY: $offsetY)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = showsIndicators
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = context.coordinator

        let host = UIHostingController(rootView: AnyView(content))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // lock width so it scrolls vertically like SwiftUI ScrollView
            host.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        context.coordinator.host = host
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.showsVerticalScrollIndicator = showsIndicators
        context.coordinator.host?.rootView = AnyView(content)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding var offsetY: CGFloat
        var host: UIHostingController<AnyView>?

        private var lastSent: CGFloat = .zero

        init(offsetY: Binding<CGFloat>) {
            _offsetY = offsetY
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let y = scrollView.contentOffset.y

            // tiny throttle to avoid spamming SwiftUI updates
            if abs(y - lastSent) < 0.5 { return }
            lastSent = y

            // ensure state updates happen cleanly
            DispatchQueue.main.async {
                self.offsetY = y
            }
        }
    }
}
