//
//  ProfileView.swift
//  ProfileNew
//
//  Created by Артем Васин on 14.02.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models
import FeedNew
import PhotosUI

public struct ProfileView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel: ProfileViewModel

    @State private var feedPage: FeedPage = .normalFeed

    @State private var showAvatarPicker: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    public init(userId: String) {
        _viewModel = .init(wrappedValue: .init(userId: userId))
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 9) {
                            ProfileInfoHeaderView(user: user, bio: viewModel.fetchedBio, showAvatarPicker: $showAvatarPicker)
                                .padding(.horizontal, 20)
                            FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
                                .padding(.horizontal, 20)
                            FeedTabControllerView(feedPage: $feedPage)
                        }
                        
                        let transiotions = NormalFeedViewModel.Transitions(
                            openProfile: { userID in
                                router.navigate(to: .accountDetail(id: userID))
                            },
                            showComments: { post in
                                router.presentedSheet = .comments(
                                    post: post,
                                    isBackgroundWhite: post.contentType == .text ? true : false,
                                    transitions: .init(openProfile: { userID in
                                        router.navigate(to: .accountDetail(id: userID))
                                    })
                                )
                            })
                        
                        switch feedPage {
                        case .normalFeed:
                            let regualarVM = NormalFeedViewModel(userId: user.id, feedType: .regular, apiService: apiManager.apiService, filters: .shared, transitions: transiotions)
                            NormalFeedView(viewModel: regualarVM)
                        case .videoFeed:
                            EmptyView()
                        case .audioFeed:
                            let audioVM = NormalFeedViewModel(userId: user.id, feedType: .audio, apiService: apiManager.apiService, filters: .shared, transitions: transiotions)
                            AudioFeedView(viewModel: audioVM)
                        }
                    }
                }
                .refreshable {
                    HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
                    await viewModel.fetchUser()
                }
            }
        }
        .background {
            Colors.textActive
                .ignoresSafeArea(.all)
        }
        .confirmationDialog("Edit profile picture", isPresented: $showAvatarPicker) {
            Button("Edit Photo") {
                isImagePickerPresented = true
            }
        }
        .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) {
            loadImage()
        }
        .onAppear {
            viewModel.apiService = apiManager.apiService
            Task {
                await viewModel.fetchUser()
                await viewModel.fetchBio()
            }
        }
    }
    
    private func loadImage() {
        guard let selectedPhotoItem else { return }
        
        Task {
            if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                do {
                    try await viewModel.uploadProfileImage(uiImage)
                    showPopup(text: "Profile picture updated successfully.")
                } catch {
                    showPopup(text: "Failed to update profile picture.")
                }

                self.selectedPhotoItem = nil
            }
        }
    }

    private struct NormalFeedView: View {
        @StateObject private var viewModel: NormalFeedViewModel

        init(viewModel: NormalFeedViewModel) {
            _viewModel = .init(wrappedValue: viewModel)
        }

        var body: some View {
            LazyVStack(alignment: .center, spacing: 20) {
                PostsListView(fetcher: viewModel, navigator: viewModel.transitions)
                    .onAppear {
                        viewModel.fetchPosts(reset: true)
                    }
            }
            .padding(.bottom, 10)
        }
    }

    private struct AudioFeedView: View {
        @StateObject private var viewModel: NormalFeedViewModel

        init(viewModel: NormalFeedViewModel) {
            _viewModel = .init(wrappedValue: viewModel)
        }

        var body: some View {
            LazyVStack(alignment: .center, spacing: 20) {
                PostsListView(fetcher: viewModel, navigator: viewModel.transitions)
                    .onAppear {
                        viewModel.fetchPosts(reset: true)
                    }
            }
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    ProfileView(userId: User.placeholder().id)
}
