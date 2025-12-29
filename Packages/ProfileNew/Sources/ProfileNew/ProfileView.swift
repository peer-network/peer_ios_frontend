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
import FeedList

public struct ProfileView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var apiManager: APIServiceManager
    
    @StateObject private var viewModel: ProfileViewModel
    @StateObject private var regularFeedVM: RegularFeedVM
    @StateObject private var audioFeedVM: AudioFeedViewModel
    @StateObject private var videoFeedVM: VideoFeedViewModel

    @State private var feedPage: FeedPage = .normalFeed
    
    @State private var showAvatarPicker: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    public init(userId: String) {
        _viewModel = .init(wrappedValue: .init(userId: userId))
        _regularFeedVM = .init(wrappedValue: .init(userId: userId))
        _audioFeedVM = .init(wrappedValue: .init(userId: userId))
        _videoFeedVM = .init(wrappedValue: .init(userId: userId))
    }
    
    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            switch viewModel.profileState {
                case .loading:
                    contentView(user: .placeholder(), isLoading: true)
                        .allowsHitTesting(false)
                case .data(let user):
                    contentView(user: user, isLoading: false)
                case .error(let error):
                    ErrorView(title: "Error", description: error.localizedDescription) {
                        Task {
                            await viewModel.fetchUser()
                            await viewModel.fetchBio()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            regularFeedVM.apiService = apiManager.apiService
            audioFeedVM.apiService = apiManager.apiService
            videoFeedVM.apiService = apiManager.apiService
            Task {
                await viewModel.fetchUser()
                await viewModel.fetchBio()
                regularFeedVM.fetchPosts(reset: true)
                audioFeedVM.fetchPosts(reset: true)
                videoFeedVM.fetchPosts(reset: true)
            }
        }
        .trackScreen(AppScreen.profile)
    }
    
    private func contentView(user: User, isLoading: Bool) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                //                ProfileInfoHeaderView(user: user, bio: viewModel.fetchedBio, showAvatarPicker: $showAvatarPicker)
                //                    .padding(.horizontal, 20)
                //                    .padding(.bottom, 9)
                //                    .skeleton(isRedacted: isLoading ? true : false)
                //
                //                FollowersHeader(userId: user.id, postsCount: user.postsAmount, followersCount: user.amountFollowers, followingsCount: user.amountFollowing, friends: user.amountFriends)
                //                    .padding(.horizontal, 20)
                //                    .padding(.bottom, 9)
                //                    .skeleton(isRedacted: isLoading ? true : false)
                
                profileHeader(user: user, isLoading: isLoading)
                
                FeedTabControllerView(feedPage: $feedPage)
                
                if isLoading {
                    LazyVStack(alignment: .center, spacing: 20) {
                        ForEach(Post.placeholdersImage(count: 5)) { post in
                            //                            PostView(postVM: PostViewModel(post: post))
                            //                                .allowsHitTesting(false)
                            //                                .skeleton(isRedacted: true)
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    switch feedPage {
                        case .normalFeed:
                            RegularFeedView(viewModel: regularFeedVM)
                        case .videoFeed:
                            VideoFeedView(viewModel: videoFeedVM)
                        case .audioFeed:
                            AudioFeedView(viewModel: audioFeedVM)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.fetchUser()
            await viewModel.fetchBio()

            regularFeedVM.fetchPosts(reset: true)
            audioFeedVM.fetchPosts(reset: true)
            videoFeedVM.fetchPosts(reset: true)
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
    
    private func profileHeader(user: User, isLoading: Bool) -> some View {
        ProfileHeader(user: user, bio: viewModel.fetchedBio, showAvatarPicker: $showAvatarPicker)
            .padding(.horizontal, 20)
            .skeleton(isRedacted: isLoading ? true : false)
    }
}

#Preview {
    ProfileView(userId: User.placeholder().id)
}
