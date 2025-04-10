//
//  PostView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Environment
import NukeUI
import DesignSystem

struct PostView: View {
    @Environment(\.redactionReasons) private var reasons

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject var postVM: PostViewModel
    
    @State private var showAppleTranslation: Bool = false
    @State private var showReportAlert: Bool = false
    @State private var showBlockAlert: Bool = false

    var body: some View {
        Group {
            switch postVM.post.contentType {
                case .text:
                    textPost
                        .environment(\.isBackgroundWhite, true)
                case .image:
                    imagePost
                        .environment(\.isBackgroundWhite, false)
                case .video:
                    EmptyView() //
                case .audio:
                    audioPost
                        .environment(\.isBackgroundWhite, false)
            }
        }
        .onAppear {
            postVM.apiService = apiManager.apiService
        }
        .modifier(ViewVisibilityModifier(viewed: postVM.isViewed, viewAction: {
            Task {
                try? await postVM.toggleView()
            }
        }))
        .environmentObject(postVM)
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
                                try await postVM.toggleReport()
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
            isPresented: $showAppleTranslation, text: "\(postVM.post.title)\n\n\(postVM.post.mediaDescription)")
#endif
    }
    
    private var textPost: some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView()
            
            PostTextView()
            
//            PostTagsView()
            
            if !reasons.contains(.placeholder) {
                PostActionsView(showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert, showBlockAlert: $showBlockAlert)
            }
        }
        .padding(10)
        .background(.white)
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
    
    private var imagePost: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .top) {
                PostImagesView()
                
                PostHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            }
            
            if !reasons.contains(.placeholder) {
                PostActionsView(showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert, showBlockAlert: $showBlockAlert)
                    .padding(.horizontal, 20)
            }

            Button {
                router.presentedSheet = .comments(
                    post: postVM.post,
                    isBackgroundWhite: postVM.post.contentType == .text ? true : false)
            } label: {
                PostDescriptionComment(isInFeed: true)
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 20)
        }
        .geometryGroup()
    }

    private var audioPost: some View {
        VStack(alignment: .center, spacing: 10) {
            PostHeaderView()

            PostTextView()

            PostAudioView()

            if !reasons.contains(.placeholder) {
                PostActionsView(showAppleTranslation: $showAppleTranslation, showReportAlert: $showReportAlert, showBlockAlert: $showBlockAlert)
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
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        VStack {
            PostView(postVM: .init(post: .placeholderText()))
                .environmentObject(APIServiceManager(.mock))
                .padding(20)
                .redacted(reason: .placeholder)
            
            PostView(postVM: .init(post: .placeholderText()))
                .environmentObject(APIServiceManager(.mock))
                .padding(20)
        }
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
    }
}
