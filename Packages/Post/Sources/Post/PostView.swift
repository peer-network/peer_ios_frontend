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
    @State private var showReportAlert: Bool = false
    @State private var showBlockAlert: Bool = false

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
                    videoPost()
                case .audio:
                    audioPost()
            }
        }
        .onFirstAppear {
            postVM.apiService = apiManager.apiService
        }
        .ifCondition(reasons != .placeholder) {
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
                .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.fraction(0.75), .large])
                .presentationContentInteraction(.resizes)
        }
        .alert(
            isPresented: $showReportAlert,
            content: {
                Alert(
                    title: Text("Confirm"),
                    message: Text("Are you sure you want to report this post?"),
                    primaryButton: .destructive(
                        Text("Report")
                    ) {
                        Task {
                            do {
                                try await postVM.report()
                                showPopup(text: "Post was reported.")
                            } catch let error as PostActionError {
                                showPopup(
                                    text: error.displayMessage,
                                    icon: error.displayIcon
                                )
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        )
#if canImport(_Translation_SwiftUI)
        .addTranslateView(
            isPresented: $showAppleTranslation, text: "\(postVM.post.title)\n\n\(postVM.description ?? "")")
#endif
    }

    private func textPost() -> some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView(postVM: postVM, showFollowButton: showFollowButton)

            TextContent(postVM: postVM)

            if !reasons.contains(.placeholder) {
                PostActionsView(layout: .horizontal, postViewModel: postVM, showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert)
            }
        }
        .padding(10)
        .background(Colors.textActive)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 1)
                .stroke(.white.opacity(0.11), lineWidth: 2)
        )
        .padding(.horizontal, 10)
        .geometryGroup()
    }

    private func imagePost() -> some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .top) {
                ImagesContent(postVM: postVM)

                PostHeaderView(postVM: postVM, showFollowButton: showFollowButton)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            }

            if !reasons.contains(.placeholder) {
                PostActionsView(layout: .horizontal, postViewModel: postVM, showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert)
                    .padding(.horizontal, 20)
            } else {
                Spacer()
                    .frame(height: 8)
            }

            Button {
                postVM.showComments()
            } label: {
                PostDescriptionComment(postVM: postVM, isInFeed: true)
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 20)
        }
        .geometryGroup()
    }

    private func audioPost() -> some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView(postVM: postVM, showFollowButton: showFollowButton)

            TextContent(postVM: postVM)

            AudioContent(postVM: postVM)

            if !reasons.contains(.placeholder) {
                PostActionsView(layout: .horizontal, postViewModel: postVM, showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert)
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
            ReelView(postVM: postVM, size: geo.size, showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert)
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
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
