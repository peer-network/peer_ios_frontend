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
import Analytics

public struct ProfileView: View {
    @Environment(\.analytics) private var analytics

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

                        switch feedPage {
                            case .normalFeed:
                                NormalFeedView(userId: user.id)
                            case .videoFeed:
                                EmptyView()
                            case .audioFeed:
                                AudioFeedView(userId: user.id)
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
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            Task {
                await viewModel.fetchUser()
                await viewModel.fetchBio()
            }
        }
        .trackScreen(AppScreen.profile)
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
        @EnvironmentObject private var apiManager: APIServiceManager
        @StateObject private var normalFeedVM: NormalFeedViewModel

        init(userId: String) {
            _normalFeedVM = .init(wrappedValue: .init(userId: userId))
        }

        var body: some View {
            LazyVStack(alignment: .center, spacing: 20) {
                PostsListView(fetcher: normalFeedVM)
                    .onFirstAppear {
                        normalFeedVM.apiService = apiManager.apiService
                        normalFeedVM.fetchPosts(reset: true)
                    }
            }
            .padding(.bottom, 10)
        }
    }

    private struct AudioFeedView: View {
        @EnvironmentObject private var apiManager: APIServiceManager
        @StateObject private var audioFeedVM: AudioFeedViewModel

        init(userId: String) {
            _audioFeedVM = .init(wrappedValue: .init(userId: userId))
        }

        var body: some View {
            LazyVStack(alignment: .center, spacing: 20) {
                PostsListView(fetcher: audioFeedVM)
                    .onFirstAppear {
                        audioFeedVM.apiService = apiManager.apiService
                        audioFeedVM.fetchPosts(reset: true)
                    }
            }
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    ProfileView(userId: User.placeholder().id)
}
