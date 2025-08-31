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
                    }
                case .video:
                    switch displayType {
                        case .list:
                            videoPost()
                        case .grid:
                            videoGridPost()
                    }
                case .audio:
                    audioPost()
            }
        }
        .debugBorder()
        .onFirstAppear {
            postVM.apiService = apiManager.apiService
        }
        .ifCondition(reasons != .placeholder && displayType == .list) {
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

            TextContent(postVM: postVM)

            if !reasons.contains(.placeholder) {
                PostActionsView(layout: .horizontal, postViewModel: postVM)
                    .background {
                        Ellipse()
                            .fill(Color(red: 0, green: 0.412, blue: 1).opacity(0.2))
                            .frame(width: 195, height: 106)
                            .offset(x: 195 / 3, y: -20)
                            .blur(radius: 50)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .ignoresSafeArea()
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
        VStack(alignment: .center, spacing: 0) {
            PostHeaderView(postVM: postVM, showAppleTranslation: $showAppleTranslation, showFollowButton: showFollowButton)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

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

            if !reasons.contains(.placeholder) {
                PostActionsView(layout: .horizontal, postViewModel: postVM)
                    .padding(.horizontal, 20)
            } else {
                Spacer()
                    .frame(height: 8)
            }

            PostDescriptionComment(postVM: postVM, isInFeed: true)
                .padding(.horizontal, 20)
        }
        .geometryGroup()
//        .contextMenu {
//            Button {
//                //
//            } label: {
//                Text("Report")
//            }
//        }
    }

    private func audioPost() -> some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView(postVM: postVM, showAppleTranslation: $showAppleTranslation, showFollowButton: showFollowButton)

            TextContent(postVM: postVM)

            AudioContent(postVM: postVM)

            if !reasons.contains(.placeholder) {
                PostActionsView(layout: .horizontal, postViewModel: postVM)
                    .padding(10)
            }
        }
        .padding(10)
        .background {
            if let url = postVM.post.coverURL {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay {
                                Gradients.blackHover
                            }
                    } else {
                        Colors.textActive
                    }
                }
            } else {
                Colors.textActive
            }
        }
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 10)
        .contentShape(.rect)
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
        .contentShape(Rectangle())
        .onTapGesture {
            router.navigate(to: .postDetailsWithPost(post: postVM.post))
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
                router.navigate(to: .postDetailsWithPost(post: postVM.post))
            }
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
    }
}
