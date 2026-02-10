//
//  PostView.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import Environment
import NukeUI
import DesignSystem

public struct PostView: View {
    @frozen
    public enum DisplayType {
        case list
        case grid
    }

    @Environment(\.redactionReasons) private var reasons

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var postVM: PostViewModel

    @State private var showAppleTranslation: Bool = false
    @State private var shareSheetHeight: Double = 20

    private let displayType: DisplayType
    private let showFollowButton: Bool

    public init(postVM: PostViewModel, displayType: DisplayType, showFollowButton: Bool) {
        _postVM = StateObject(wrappedValue: postVM)
        self.displayType = displayType
        self.showFollowButton = showFollowButton
    }

    public var body: some View {
        Group {
            switch postVM.post.contentType {
                case .text:
                    textPost()
                case .image:
                    switch displayType {
                        case .list:
                            imagePost()
                        case .grid:
                            imageGridPost()
                                .ifCondition(postVM.showSensitiveContentWarning) {
                                    $0
                                        .blur(radius: 7.38)
                                        .overlay {
                                            Circle()
                                                .frame(height: 50)
                                                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                                                .overlay {
                                                    IconsNew.eyeWithSlash
                                                        .iconSize(height: 27)
                                                        .foregroundStyle(Colors.whitePrimary)
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        }
                                        .clipped()
                                        .onTapGesture {
                                            router.navigate(to: RouterDestination.postDetailsWithPost(post: postVM.post))
                                        }
                                }
                                .ifCondition(postVM.showIllegalBlur) {
                                    $0
                                        .blur(radius: 7.38)
                                        .overlay {
                                            Circle()
                                                .frame(height: 50)
                                                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                                                .overlay {
                                                    Icons.trashBin
                                                        .iconSize(height: 27)
                                                        .foregroundStyle(Colors.whitePrimary)
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        }
                                        .clipped()
                                        .onTapGesture {
                                            router.navigate(to: RouterDestination.postDetailsWithPost(post: postVM.post))
                                        }
                                }
                    }
                case .video:
                    switch displayType {
                        case .list:
                            videoPost()
                        case .grid:
                            videoGridPost()
                                .ifCondition(postVM.showSensitiveContentWarning) {
                                    $0
                                        .blur(radius: 7.38)
                                        .overlay {
                                            Circle()
                                                .frame(height: 50)
                                                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                                                .overlay {
                                                    IconsNew.eyeWithSlash
                                                        .iconSize(height: 27)
                                                        .foregroundStyle(Colors.whitePrimary)
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        }
                                        .clipped()
                                        .onTapGesture {
                                            router.navigate(to: RouterDestination.postDetailsWithPost(post: postVM.post))
                                        }
                                }
                                .ifCondition(postVM.showIllegalBlur) {
                                    $0
                                        .blur(radius: 7.38)
                                        .overlay {
                                            Circle()
                                                .frame(height: 50)
                                                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                                                .overlay {
                                                    Icons.trashBin
                                                        .iconSize(height: 27)
                                                        .foregroundStyle(Colors.whitePrimary)
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        }
                                        .clipped()
                                        .onTapGesture {
                                            router.navigate(to: RouterDestination.postDetailsWithPost(post: postVM.post))
                                        }
                                }
                    }
                case .audio:
                    audioPost()
            }
        }
        .onFirstAppear {
            postVM.apiService = apiManager.apiService
        }
        .ifCondition(reasons != .placeholder && displayType == .list && !postVM.showIllegalBlur) {
            $0.modifier(ViewVisibilityModifier(viewed: postVM.isViewed, viewAction: {
                Task {
                    try? await postVM.view()
                }
            }))
        }
        .sheet(isPresented: $postVM.showCommentsSheet) {
            CommentsListView(viewModel: postVM)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .presentationBackground(Colors.blackDark)
                .presentationDetents([.fraction(0.75), .large])
                .presentationContentInteraction(.resizes)
        }
        .sheet(isPresented: $postVM.showInteractionsSheet) {
            InteractionsView(viewModel: postVM)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .presentationBackground(Colors.blackDark)
                .presentationDetents([.fraction(0.75), .large])
                .presentationContentInteraction(.resizes)
        }
        .sheet(isPresented: $postVM.showShareSheet) {
            PostShareBottomSheet(viewModel: postVM)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
                    withAnimation {
                        self.shareSheetHeight = height + 20
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .presentationBackground(Colors.blackDark)
                .presentationDetents([.height(shareSheetHeight)])
        }
        .addTranslateView(
            isPresented: $showAppleTranslation, text: "\(postVM.post.title)\n\n\(postVM.description ?? "")"
        )
    }

    private func textPost() -> some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView(postVM: postVM, showAppleTranslation: $showAppleTranslation, showFollowButton: showFollowButton)

            if postVM.showIllegalBlur {
                illegalPostView
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 171)
            } else {
                TextContent(postVM: postVM)
                    .ifCondition(postVM.showSensitiveContentWarning) {
                        $0
                            .allowsHitTesting(false)
                            .blur(radius: 15)
                            .overlay {
                                sensitiveContentWarningForTextPostView
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                    }
            }

            if !reasons.contains(.placeholder) {
                HStack(alignment: .center, spacing: 0) {
                    PostActionsView(layout: .horizontal, postViewModel: postVM)
                        .fixedSize(horizontal: true, vertical: false)

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    if AccountManager.shared.isCurrentUser(id: postVM.post.owner.id), postVM.post.isHiddenForUsers {
                        HiddenBadgeView()
                    } else if postVM.post.hasActiveReports {
                        ReportedBadgeView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background {
                    Ellipse()
                        .fill(Color(red: 0, green: 0.412, blue: 1).opacity(0.2))
                        .frame(width: 195, height: 106)
                        .offset(x: 195 / 3, y: -20)
                        .blur(radius: 50)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(10)
        .background(Colors.inactiveDark)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 10)
        .geometryGroup()
    }

    private func imagePost() -> some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView(postVM: postVM, showAppleTranslation: $showAppleTranslation, showFollowButton: showFollowButton)
                .padding(.horizontal, 10)

            if postVM.showIllegalBlur {
//                illegalPostView
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .frame(height: 150)
//                    .background(Colors.inactiveDark)
//                    .clipShape(RoundedRectangle(cornerRadius: 24))
//                    .padding(.horizontal, 20)
            } else {
                ImagesContent(postVM: postVM)
                    .doubleTapToLike {
                        try await postVM.like()
                    } onError: { error in
                        if let error = error as? PostActionError {
                            showPopup(
                                text: error.displayMessage,
                                icon: error.displayIcon
                            )
                        } else {
                            showPopup(
                                text: error.userFriendlyDescription
                            )
                        }
                    }
//                    .ifCondition(postVM.showSensitiveContentWarning) {
//                        $0
//                            .allowsHitTesting(false)
//                            .blur(radius: 25)
//                            .overlay {
//                                sensitiveContentWarningForImagePostView
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                            }
//                            .clipped()
//                    }
                    .padding(.bottom, 10)
            }

            HStack(alignment: .top, spacing: 10) {
                Text(postVM.post.title)
                    .appFont(.bodyBold)
                    .foregroundStyle(Colors.whitePrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(postVM.post.formattedCreatedAtShort)
                    .appFont(.smallLabelRegular)
                    .foregroundStyle(Colors.whiteSecondary)
            }
            .padding(.horizontal, 10)

            if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
                CollapsibleText(text, lineLimit: 1)
                    .appFont(.bodyRegular)
                    .ifCondition(postVM.showSensitiveContentWarning || postVM.showIllegalBlur) {
                        $0
                            .allowsHitTesting(false)
                            .redacted(reason: .placeholder)
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
            }
//            PostDescriptionComment(postVM: postVM, isInFeed: true)
//                .padding(.horizontal, 10)
//                .padding(.bottom, 10)

            if !reasons.contains(.placeholder) {
                HStack(alignment: .center, spacing: 0) {
                    PostActionsView(layout: .horizontal, postViewModel: postVM)
                        .fixedSize(horizontal: true, vertical: false)

                    Spacer()
                        .frame(minWidth: 10)
                        .layoutPriority(-1)

                    if AccountManager.shared.isCurrentUser(id: postVM.post.owner.id), postVM.post.isHiddenForUsers {
                        HiddenBadgeView()
                    } else if postVM.post.hasActiveReports {
                        ReportedBadgeView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 4)
        .geometryGroup()
    }

    private func audioPost() -> some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView(postVM: postVM, showAppleTranslation: $showAppleTranslation, showFollowButton: showFollowButton)

            if postVM.showIllegalBlur {
                illegalPostView
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 171)
            } else {
                VStack(alignment: .center, spacing: 10) {
                    TextContent(postVM: postVM)

                    AudioContent(postVM: postVM)
                }
                .ifCondition(postVM.showSensitiveContentWarning) {
                    $0
                        .allowsHitTesting(false)
                        .blur(radius: 15)
                        .overlay {
                            sensitiveContentWarningForTextPostView
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                }
            }

            if !reasons.contains(.placeholder) {
                HStack(alignment: .center, spacing: 0) {
                    PostActionsView(layout: .horizontal, postViewModel: postVM)
                        .fixedSize(horizontal: true, vertical: false)

                    Spacer()
                        .frame(minWidth: 10)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(-1)

                    if AccountManager.shared.isCurrentUser(id: postVM.post.owner.id), postVM.post.isHiddenForUsers {
                        HiddenBadgeView()
                    } else if postVM.post.hasActiveReports {
                        ReportedBadgeView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
        }
        .padding(10)
        .background {
            if !postVM.showIllegalBlur {
                if let url = postVM.post.coverURL {
                    LazyImage(url: url) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .overlay {
                                    Gradients.blackHover
                                }
                                .ifCondition(postVM.showSensitiveContentWarning) {
                                    $0
                                        .blur(radius: 25)
                                        .clipped()
                                }
                                .allowsHitTesting(false)
                        } else {
                            Colors.textActive
                        }
                    }
                } else {
                    Colors.textActive
                }
            } else {
                Colors.inactiveDark
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 10)
        .geometryGroup()
    }

    private func videoPost() -> some View {
        GeometryReader { geo in
            ShortVideoView2(postVM: postVM, size: geo.size, showAppleTranslation: $showAppleTranslation)
        }
        .containerRelativeFrame(.vertical)
    }

    private func videoGridPost() -> some View {
        GeometryReader { proxy in
            LazyImage(
                request: ImageRequest(
                    url: postVM.post.coverURL,
                    processors: [.resize(size: CGSize(width: 300, height: 300))])
            ) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .clipShape(Rectangle())
                } else if (state.error) != nil {
                    Colors.black
                } else {
                    Colors.imageLoadingPlaceholder
                }
            }
        }
        .overlay(alignment: .bottom) {
            HStack {
                Text(getVideoDuration(timeInterval: postVM.post.media.first?.duration))
                    .font(.customFont(weight: .regular, style: .body))

                Spacer()
                    .frame(maxWidth: .infinity)

                Icons.play
                    .iconSize(height: 16)
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(.bottom, 10)
            .padding(.horizontal, 10)
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .contentShape(.rect)
        .onTapGesture {
            router.navigate(to: RouterDestination.postDetailsWithPost(post: postVM.post))
        }
    }

    private func getVideoDuration(timeInterval: TimeInterval?) -> String {
        guard let timeInterval else {
            return ""
        }

        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    private func imageGridPost() -> some View {
        GeometryReader { proxy in
            LazyImage(
                request: ImageRequest(
                    url: postVM.post.mediaURLs.first,
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
                router.navigate(to: RouterDestination.postDetailsWithPost(post: postVM.post))
            }
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
    }

    private var sensitiveContentWarningForTextPostView: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Circle()
                    .frame(height: 50)
                    .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                    .overlay {
                        IconsNew.eyeWithSlash
                            .iconSize(height: 27)
                            .foregroundStyle(Colors.whitePrimary)
                    }
                    .padding(.bottom, 5)

                Text("Sensitive content")
                    .appFont(.bodyBold)

                Text("This content may be sensitive or abusive.\nDo you want to view it anyway?")
                    .appFont(.smallLabelRegular)
            }
            .foregroundStyle(Colors.whitePrimary)
            .fixedSize(horizontal: false, vertical: true)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            let showButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "Show")
            StateButton(config: showButtonConfig) {
                withAnimation {
                    postVM.showSensitiveContentWarning = false
                }
            }
            .fixedSize()
        }
        .multilineTextAlignment(.leading)
    }

    private var sensitiveContentWarningForImagePostView: some View {
        VStack(spacing: 0) {
            Circle()
                .frame(height: 50)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(height: 27)
                        .foregroundStyle(Colors.whitePrimary)
                }
                .padding(.bottom, 14.02)

            Text("Sensitive content")
                .appFont(.largeTitleBold)

            Text("This content may be sensitive or abusive.\nDo you want to view it anyway?")
                .appFont(.bodyRegular)
                .padding(.bottom, 10)

            let showButtonConfig = StateButtonConfig(buttonSize: .small, buttonType: .teritary, title: "View content")
            StateButton(config: showButtonConfig) {
                withAnimation {
                    postVM.showSensitiveContentWarning = false
                }
            }
            .fixedSize()
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(Colors.whitePrimary)
    }

    private var illegalPostView: some View {
        VStack(alignment: .center, spacing: 10) {
            Icons.trashBin
                .iconSize(width: 16)

            Text("This content was removed as illegal")
                .appFont(.bodyBold)
        }
        .foregroundStyle(Colors.whitePrimary)
    }
}
