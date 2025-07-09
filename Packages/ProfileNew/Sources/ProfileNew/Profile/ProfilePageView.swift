//
//  ProfilePageView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 25.05.25.
//

import SwiftUI
import Environment
import DesignSystem
import PhotosUI
import Analytics
import Models

@available(iOS 18.0, *)
public struct ProfilePageView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel: ProfileViewModel

    @State private var showAvatarPicker: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @StateObject private var regularFeedVM: RegularFeedVM
    @StateObject private var audioFeedVM: AudioFeedViewModel

    public init(userId: String) {
        _viewModel = .init(wrappedValue: .init(userId: userId))
        _regularFeedVM = .init(wrappedValue: .init(userId: userId))
        _audioFeedVM = .init(wrappedValue: .init(userId: userId))
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            pageContent
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
                await fetchEverything()
            }
        }
        .trackScreen(AppScreen.profile)
    }

    @ViewBuilder
    private var pageContent: some View {
        switch viewModel.profileState {
            case .loading:
                contentView(user: .placeholder(), isLoading: true)
                    .allowsHitTesting(false)
            case .data(let user):
                contentView(user: user, isLoading: false)
            case .error(let error):
                ErrorView(title: "Error", description: error.userFriendlyDescription) {
                    Task {
                        await fetchEverything()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func contentView(user: User, isLoading: Bool) -> some View {
        HeaderPageScrollView {
            profileHeader(user: user, isLoading: isLoading)
        } labels: {
            PageLabel(title: "Regular", icon: Icons.smile)
            PageLabel(title: "Video", icon: Icons.playRectangle)
            PageLabel(title: "Audio", icon: Icons.musicNote)
        } pages: {
            RegularFeedView(viewModel: regularFeedVM)

            Text("Work in progress...")
                .padding(20)

            AudioFeedView(viewModel: audioFeedVM)
        } onRefresh: {
            HapticManager.shared.fireHaptic(.dataRefresh(intensity: 0.3))
            await fetchEverything()
        }
    }

    private func profileHeader(user: User, isLoading: Bool) -> some View {
        ProfileHeader(user: user, bio: viewModel.fetchedBio, showAvatarPicker: $showAvatarPicker)
            .padding(.horizontal, 20)
            .skeleton(isRedacted: isLoading ? true : false)
    }

    private func fetchEverything() async {
        await viewModel.fetchUser()
        await viewModel.fetchBio()

        regularFeedVM.fetchPosts(reset: true)
        audioFeedVM.fetchPosts(reset: true)
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
}
