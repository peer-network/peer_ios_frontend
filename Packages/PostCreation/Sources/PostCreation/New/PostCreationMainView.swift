//
//  PostCreationMainView.swift
//  PostCreation
//
//  Created by Artem Vasin on 16.05.25.
//

import SwiftUI
import Environment
import Analytics
import DesignSystem
import PhotosUI

public struct PostCreationMainView: View {
    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var audioManager: AudioSessionManager

    @StateObject private var postCreationVM = PostCreationVM()

    private enum InputType: String {
        case title = "title"
        case description = "description"

        var minLength: Int {
            switch self {
                case .title: 3
                case .description: 0
            }
        }
    }

    @State private var postType: PostType = .text

    public enum FocusField: Hashable {
        case title
        case description
    }
    @FocusState private var focusedField: FocusField?

    @State private var titleText: String = ""
    @State private var descriptionText: String = ""

    @State private var titleHashtags: [String] = []
    @State private var descriptionHashtags: [String] = []

    // Attachments
    @State private var imageStates: [ImageState]?
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    @State private var videoState: VideoState?

    @State private var audioState: AudioState?

    // View logic properties
    @State private var focusOnEditing = false

    // Popups
    @State private var showConfirmationAlert: Bool = false
    @State private var showSuccessAlert: Bool = false

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .posts) {
            Text("New Post")
        } content: {
            ScrollView {
                VStack(spacing: 20) {
                    AttachmentMainView(focusOnEditing: $focusOnEditing, postType: $postType, imageStates: $imageStates, selectedPhotoItems: $selectedPhotoItems, videoState: $videoState, audioState: $audioState)

                    if !focusOnEditing {
                        VStack(spacing: 20) {
                            Text("Title")
                                .font(.customFont(style: .callout))
                                .foregroundStyle(Colors.whiteSecondary)
                                .padding(.bottom, -10)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            BorderedTextFieldCharsCount(
                                text: $titleText,
                                hashtags: $titleHashtags,
                                minHeight: 30,
                                placeholder: "Write a title...",
                                maxLength: 50,
                                allowNewLines: false,
                                focusState: $focusedField,
                                focusEquals: .title
                            )

                            let descrtiptionText = postType == .text ? "Description" : "Description (optional)"
                            Text(descrtiptionText)
                                .font(.customFont(style: .callout))
                                .foregroundStyle(Colors.whiteSecondary)
                                .padding(.bottom, -10)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            BorderedTextFieldCharsCount(
                                text: $descriptionText,
                                hashtags: $descriptionHashtags,
                                minHeight: 90,
                                placeholder: "Write a description...",
                                maxLength: postType == .text ? 20000 : 500,
                                allowNewLines: true,
                                focusState: $focusedField,
                                focusEquals: .description
                            )

                            if !postCreationVM.error.isEmpty {
                                Text(postCreationVM.error)
                                    .font(.customFont(weight: .regular, size: .footnote))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Colors.warning)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            FloatingNavigationButtons {
                                focusedField = nil
                                withAnimation {
                                    reset()
                                }
                            } postAction: {
                                focusedField = nil
                                withAnimation {
                                    showConfirmationAlert = true
                                }
                            }
                        }
                        .transition(.blurReplace)
                    }
                }
                .padding(.top, 7)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .overlay {
                if showConfirmationAlert {
                    Colors.whitePrimary.opacity(0.2).blur(radius: 10).ignoresSafeArea(edges: .all)
                    postConfirmationView(isFreePost: accountManager.dailyFreePosts > 0 ? true : false)
                        .padding(.horizontal, 20)
                }
                if postCreationVM.isLoading {
                    Colors.whitePrimary.opacity(0.2).blur(radius: 10).ignoresSafeArea(edges: .all)
                    ProgressView()
                        .controlSize(.extraLarge)
                }
                if showSuccessAlert {
                    Colors.whitePrimary.opacity(0.2).blur(radius: 10).ignoresSafeArea(edges: .all)
                    successView
                        .padding(.horizontal, 20)
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onChange(of: focusOnEditing) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            audioManager.isInRestrictedView = true
        }
        .onDisappear {
            audioManager.isInRestrictedView = false
        }
        .onFirstAppear {
            postCreationVM.apiService = apiManager.apiService
            postCreationVM.accountManager = accountManager
        }
        .trackScreen(AppScreen.postCreation)
    }

    private func postButtonClicked() {
        Task {
            let result = await makePost()

            if result {
                withAnimation {
                    reset()
                    showSuccessAlert = true
                }
            }
        }
    }

    private func makePost() async -> Bool {
        let combinedHashtags = Array(Set(titleHashtags + descriptionHashtags))

        var result: Bool = false
        switch postType {
            case .photo:
                let images = getPhotos()
                result = await postCreationVM.makePhotoPost(title: titleText, description: descriptionText, images: images, hashtags: combinedHashtags)
            case .video:
                guard let videoURL = getVideoURL() else { return false }
                result = await postCreationVM.makeVideoPost(title: titleText, description: descriptionText, hashtags: combinedHashtags, videoURL: videoURL)
            case .audio:
                guard let audioURL = getAudioURL() else { return false }
                let coverImage = getAudioCoverImage()
                result = await postCreationVM.makeAudioPost(title: titleText, description: descriptionText, hashtags: combinedHashtags, audioURL: audioURL, cover: coverImage)
            case .text:
                result = await postCreationVM.makeTextPost(title: titleText, description: descriptionText, hashtags: combinedHashtags)
        }

        return result
    }

    private func getPhotos() -> [UIImage] {
        guard let imageStates else { return [] }

        return imageStates.compactMap { state in
            if case .loaded(let image) = state.state {
                return image
            }
            return nil
        }
    }

    private func getVideoURL() -> URL? {
        guard let videoState else { return nil }

        if case .loaded(_, let videoURL, _) = videoState.state {
            return videoURL
        }

        return nil
    }

    private func getAudioURL() -> URL? {
        guard let audioState else { return nil }
        return audioState.url
    }

    private func getAudioCoverImage() -> UIImage? {
        guard let audioState else { return nil }
        guard let coverState = audioState.cover else { return nil }

        if case .loaded(let image) = coverState.state {
            return image
        }

        return nil
    }

    private func reset() {
        postCreationVM.error = ""
        focusedField = nil
        postType = .text
        titleText = ""
        titleHashtags = []
        descriptionText = ""
        descriptionHashtags = []
        imageStates = nil
        selectedPhotoItems = []
        videoState = nil
        audioState = nil
    }

    @ViewBuilder
    private func postConfirmationView(isFreePost: Bool) -> some View {
        let text = isFreePost ? "You will spend 1 free daily post " : "You will pay 20 tokens for this post"

        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                Icons.plustSquare
                    .iconSize(height: 21)

                Text(text)
            }

            Text("You will not be able to edit your post afterwards.")
                .foregroundStyle(Colors.whiteSecondary)

            Button {
                showConfirmationAlert = false
                postButtonClicked()
            } label: {
                Text("Post")
            }
            .buttonStyle(TargetButtonStyle())

            Button {
                showConfirmationAlert = false
            } label: {
                Text("Back")
            }
            .buttonStyle(StrokeButtonStyle())
            .padding(.top, -10)
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(style: .footnote))
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Colors.inactiveDark))
    }

    private var successView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                Icons.plustSquare
                    .iconSize(height: 21)

                Text("Post created successfully!")
            }

            Button {
                showSuccessAlert = false
            } label: {
                Text("Continue")
            }
            .buttonStyle(TargetButtonStyle())
        }
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(style: .footnote))
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Colors.inactiveDark))
    }
}

#Preview {
    PostCreationMainView()
        .analyticsService(MockAnalyticsService())
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
