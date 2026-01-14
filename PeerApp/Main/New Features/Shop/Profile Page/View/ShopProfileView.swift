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
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: fullHeaderHeight + tabControllerHeight + 10)

                            shopItemsView
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                        }
                    }
                    .background(ScrollViewOffsetObserver(offsetY: $offsetY17))
                    .onChange(of: offsetY17) {
                        print("offsetY17:", offsetY17)
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
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - iOS 17 ScrollView offset observer

private struct ScrollViewOffsetObserver: UIViewRepresentable {
    @Binding var offsetY: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(offsetY: $offsetY)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        // Attach after the view is in hierarchy
        DispatchQueue.main.async {
            context.coordinator.attachIfPossible(from: view)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Re-attach if SwiftUI rebuilt hierarchy
        DispatchQueue.main.async {
            context.coordinator.attachIfPossible(from: uiView)
        }
    }

    final class Coordinator: NSObject {
        @Binding var offsetY: CGFloat
        private weak var scrollView: UIScrollView?
        private var observation: NSKeyValueObservation?
        private var lastSent: CGFloat = .zero

        init(offsetY: Binding<CGFloat>) {
            _offsetY = offsetY
        }

        func attachIfPossible(from view: UIView) {
            guard let sv = view.findEnclosingScrollView() else { return }

            // Already attached
            if scrollView === sv { return }

            scrollView = sv
            observation?.invalidate()

            // Set initial value (top should be 0)
            sendOffset(from: sv)

            observation = sv.observe(\.contentOffset, options: [.new]) { [weak self] sv, _ in
                guard let self else { return }
                self.sendOffset(from: sv)
            }
        }

        private func sendOffset(from sv: UIScrollView) {
            // SwiftUI ScrollView usually sits at -adjustedContentInset.top at rest.
            let y = sv.contentOffset.y + sv.adjustedContentInset.top
            let clamped = max(0, y)

            // tiny throttle
            if abs(clamped - lastSent) < 0.5 { return }
            lastSent = clamped

            DispatchQueue.main.async {
                self.offsetY = clamped
            }
        }
    }
}

private extension UIView {
    func findEnclosingScrollView() -> UIScrollView? {
        var v: UIView? = self
        while let current = v {
            if let sv = current as? UIScrollView { return sv }
            v = current.superview
        }
        return nil
    }
}
