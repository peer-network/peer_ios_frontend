//
//  PostCreationView.swift
//  PostCreation
//
//  Created by Артем Васин on 11.02.25.
//

import SwiftUI
import DesignSystem
import Environment
import Photos
import Models
import PhotosUI

public struct PostCreationView: View {
    @Environment(\.openURL) var openURL

    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var audioManager: AudioSessionManager

    @StateObject private var viewModel = PostCreationViewModel()
    @StateObject private var photoLibrary = PhotoLibraryViewModel()

    @State private var selectedPhotoAssets: [PHAsset] = []
    @State private var selectedShortVideoAsset: PHAsset? = nil
    @State private var selectedShortVideoURL: URL? = nil
    @State private var selectedLongVideoAsset: PHAsset? = nil
    @State private var selectedLongVideoURL: URL? = nil

    // Audio posts
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedCoverAsset: UIImage? = nil
    @State private var selectedAudioURL: URL? = nil
    @State private var isDocumentPickerPresented = false

    @State private var showPostAlert = false
    @State private var postAlertMessage = ""

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 1)
    ]

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .posts) {
            Text("New Post")
        } content: {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Group {
                            if viewModel.allMediaSelected {
                                switch viewModel.selectedType {
                                    case .image:
                                        EmptyView()
                                    case .video:
                                        EmptyView()
                                    case .text:
                                        EmptyView()
                                    case .audio:
                                        EmptyView()
                                }
                            } else {
                                switch viewModel.selectedType {
                                    case .image:
                                        photosPreviewView
                                    case .video:
                                        videoPostGuideView
                                    case .text:
                                        EmptyView()
                                    case .audio:
                                        audioPostButtonsView
                                }
                            }
                        }
                        
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            Section {
                                Group {
                                    if viewModel.allMediaSelected || viewModel.selectedType == .text {
                                        switch viewModel.selectedType {
                                            case .image:
                                                TextEditorView()
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 16)
                                                    .id("test")
                                            case .video:
                                                TextEditorView()
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 16)
                                                    .id("test")
                                            case .text:
                                                TextEditorView()
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 16)
                                                    .id("test")
                                            case .audio:
                                                TextEditorView()
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 16)
                                                    .id("test")
                                        }
                                    } else {
                                        switch viewModel.selectedType {
                                            case .image:
                                                photosScrollView
                                            case .video:
                                                Group {
                                                    switch viewModel.selectedVideoType {
                                                        case .none:
                                                            EmptyView()
                                                        case .short:
                                                            shortVideosScrollView
                                                        case .shortAndLong:
                                                            switch viewModel.currentShortAndLongVideoSelection {
                                                                case .short:
                                                                    shortVideosScrollView
                                                                case .long:
                                                                    longVideosScrollView
                                                            }
                                                    }
                                                }
                                            case .text:
                                                EmptyView()
                                            case .audio:
                                                EmptyView()
                                        }
                                    }
                                }
                            } header: {
                                PostTypeHeaderView(selectedType: $viewModel.selectedType)
                            }
                        }
                        .onChange(of: viewModel.allMediaSelected) {
                            if viewModel.allMediaSelected {
                                withAnimation{
                                    proxy.scrollTo("test")
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                //                .scrollIndicators(.hidden)
                .overlay {
                    if let selectedShortVideoAsset, let selectedShortVideoURL, viewModel.currentShortAndLongVideoSelection == .short {
                        //                    VideoConfirmationView(asset: selectedShortVideoAsset) { trimmedAsset in
                        //    //                    self.trimmedVideo = trimmedAsset
                        //                    }
                        //                    .padding(.horizontal, 20)
                        //                    .padding b(.bottom, 39)

                        KVideoTrimmer(isLong: false, url: selectedShortVideoURL, minimumDurationInSeconds: 5, maximumDurationInSeconds: 30, quality: .medium, outputFileType: .mp4) { url, error in
                            if error == nil {
                                self.selectedShortVideoURL = url
                                self.selectedShortVideoAsset = nil
                                self.viewModel.currentShortAndLongVideoSelection = .long
                            } else {
                                print(error)
                                self.selectedShortVideoAsset = nil
                                self.selectedShortVideoURL = nil
                            }
                        } onClose: {
                            self.selectedShortVideoAsset = nil
                            self.selectedShortVideoURL = nil
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 39)
                        .background(Colors.whitePrimary.opacity(0.01).ignoresSafeArea(edges: .all))
                    }
                }
                .overlay {
                    if let selectedLongVideoURL, let selectedLongVideoAsset, viewModel.currentShortAndLongVideoSelection == .long {
                        KVideoTrimmer(isLong: true, url: selectedLongVideoURL, minimumDurationInSeconds: 60, maximumDurationInSeconds: 300, quality: .high, outputFileType: .mp4) { url, error in
                            if error == nil {
                                self.selectedLongVideoURL = url
                                self.selectedLongVideoAsset = nil
                                self.viewModel.allMediaSelected = true
                            } else {
                                print(error)
                                self.selectedLongVideoAsset = nil
                                self.selectedLongVideoURL = nil
                            }
                        } onClose: {
                            self.selectedLongVideoAsset = nil
                            self.selectedLongVideoURL = nil
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 39)
                        .background(Colors.whitePrimary.opacity(0.01).ignoresSafeArea(edges: .all))
                    }
                }
                .overlay {
                    if let selectedShortVideoURL, let selectedShortVideoAsset, viewModel.selectedVideoType == .short {
                        KVideoTrimmer(isLong: false, url: selectedShortVideoURL, minimumDurationInSeconds: 5, maximumDurationInSeconds: 30, quality: .high, outputFileType: .mp4) { url, error in
                            if error == nil {
                                self.selectedShortVideoURL = url
                                self.selectedShortVideoAsset = nil
                                self.viewModel.allMediaSelected = true
                            } else {
                                print(error)
                                self.selectedShortVideoAsset = nil
                                self.selectedShortVideoURL = nil
                            }
                        } onClose: {
                            self.selectedShortVideoAsset = nil
                            self.selectedShortVideoURL = nil
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 39)
                        .background(Colors.whitePrimary.opacity(0.01).ignoresSafeArea(edges: .all))
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !selectedPhotoAssets.isEmpty && !viewModel.allMediaSelected {
                FloatingProceedView(description: {
                    Text("^[\(selectedPhotoAssets.count) photo](inflect: true) selected")
                        .animation(nil)
                }, proceed: {
                    HStack {
                        Text("Continue")
                        Spacer()
                        Icons.arrowDownNormal
                            .foregroundColor(Colors.whitePrimary)
                            .rotationEffect(.degrees(270))
                    }
                }, action: {
                    viewModel.allMediaSelected = true
                }, disabled: false)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                .transition(.move(edge: .bottom).animation(.linear))
            }
        }
        .overlay(alignment: .bottom) {
            if selectedAudioURL != nil && !viewModel.allMediaSelected {
                FloatingProceedView(description: {
                    Text("Audio selected")
                        .animation(nil)
                }, proceed: {
                    HStack {
                        Text("Continue")
                        Spacer()
                        Icons.arrowDownNormal
                            .foregroundColor(Colors.whitePrimary)
                            .rotationEffect(.degrees(270))
                    }
                }, action: {
                    viewModel.allMediaSelected = true
                }, disabled: false)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                .transition(.move(edge: .bottom).animation(.linear))
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.allMediaSelected || viewModel.selectedType == .text {
                FloatingProceedView(description: {
                    Group {
                        if accountManager.dailyFreePosts > 0 {
                            HStack(spacing: 10) {
                                Icons.plustSquare
                                    .iconSize(height: 13)
                                Text("You will spend 1 free post")
                            }
                        } else {
                            HStack(spacing: 10) {
                                Icons.plustSquare
                                    .iconSize(height: 13)
                                Text("You will spend 20")
                                Icons.logoCircleWhite
                                    .iconSize(height: 13)
                            }
                        }
                    }
                }, proceed: {
                    HStack {
                        Text("Post")
                        Spacer()
                        Icons.arrowDownNormal
                            .foregroundColor(Colors.whitePrimary)
                            .rotationEffect(.degrees(270))
                    }
                }, action: {
                    Task {
                        let result =
                        switch viewModel.selectedType {
                            case .text:
                                await viewModel.makePost()
                            case .image:
                                await viewModel.makePost(photos: selectedPhotoAssets)
                            case .video:
                                await viewModel.makePost(shortVideoURL: selectedShortVideoURL, longVideoURL: selectedLongVideoURL)
                            case .audio:
                                await viewModel.makeAudioPost(audio: selectedAudioURL!, cover: selectedCoverAsset)
                        }

                        if result {
                            postAlertMessage = "Successfully posted"
                        } else {
                            postAlertMessage = "Failed to create post"
                        }
                        showPostAlert = true
                    }
                }, disabled: !viewModel.canPost || (viewModel.postText.string.isEmpty && viewModel.selectedType == .text))
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                .transition(.move(edge: .bottom).animation(.linear))
            }
        }
        .alert(postAlertMessage, isPresented: $showPostAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            photoLibrary.requestAuthorizationAndFetch()
            if accountManager.dailyFreePosts < 1 {
                showPopup(
                    text: "No free posts left for today. Next post will cost you 20",
                    icon: Icons.exclamationMarkTriangleWhite,
                    backIcon: Icons.logoCircleWhite
                )
            }
        }
        .onChange(of: viewModel.selectedType) {
            viewModel.allMediaSelected = false
            selectedPhotoAssets = []
            viewModel.selectedVideoType = .none
            viewModel.currentShortAndLongVideoSelection = .short
            selectedLongVideoAsset = nil
            selectedShortVideoAsset = nil
            selectedShortVideoURL = nil
            selectedLongVideoURL = nil
            selectedPhoto = nil
            selectedCoverAsset = nil
            selectedAudioURL = nil
            viewModel.postTitle = ""
            viewModel.postText = NSMutableAttributedString(string: "")

            switch viewModel.selectedType {
                case .image:
                    Task {
                        await photoLibrary.fetchPhotos()
                    }
                case .video:
                    Task {
//                        await photoLibrary.fetchShortVideos()
                        await photoLibrary.fetchLongVideos()
                    }
                case .text:
                    break
                case .audio:
                    break
            }
        }
        .ifCondition(viewModel.isCreatingPost) {
            $0.overlay {
                Colors.whitePrimary.opacity(0.1).ignoresSafeArea(edges: .all)
                ProgressView()
                    .controlSize(.extraLarge)
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.apiService = apiManager.apiService
            
            audioManager.isInRestrictedView = true
        }
        .onDisappear {
            audioManager.isInRestrictedView = false
        }
    }

    private func openSettings() {
        openURL(URL(string: UIApplication.openSettingsURLString)!)
    }
}


// MARK: - Photo post

extension PostCreationView {
    private var photosPreviewView: some View {
        Group {
            if !selectedPhotoAssets.isEmpty {
                TabView {
                    ForEach(selectedPhotoAssets, id: \.localIdentifier) { asset in
                        PhotoThumbnail(
                            asset: asset,
                            size: CGSize(width: 1000, height: 1000))
                        .scaledToFit()
                        .clipped()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            } else {
                if let latestAsset = photoLibrary.photoAssets.first {
                    PhotoThumbnail(
                        asset: latestAsset,
                        size: CGSize(width: 1000, height: 1000)
                    )
                    .scaledToFit()
                    .clipped()
                } else {
                    ProgressView()
                        .controlSize(.extraLarge)
                }
            }
        }
        .frame(width: getRect().width, height: getRect().height / 2.2)
        .background(Gradients.blackHover)
    }

    @ViewBuilder
    private var photosScrollView: some View {
        if photoLibrary.photoAccessGranted {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(photoLibrary.photoAssets, id: \.localIdentifier) { asset in
                    GeometryReader { proxy in
                        PhotoThumbnail(
                            asset: asset,
                            size: CGSize(width: 300, height: 300)
                        )
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .onTapGesture {
                            togglePhotoSelection(for: asset)
                        }
                    }
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                    .ifCondition(selectedPhotoAssets.contains(where: { $0.localIdentifier == asset.localIdentifier })) {
                        $0.overlay {
                            Color.black.opacity(0.5)
                                .allowsHitTesting(false)
                        }
                    }
                    .ifCondition(selectedPhotoAssets.contains(where: { $0.localIdentifier == asset.localIdentifier })) {
                        $0.overlay(alignment: .bottomTrailing) {
                            photoSelectionIndicatorView(for: asset)
                                .frame(width: 17, height: 17)
                                .offset(x: -5, y: -5)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        } else {
            photoAccessDeniedView
        }
    }

    private var photoAccessDeniedView: some View {
        VStack(spacing: 0) {
            Icons.block
                .iconSize(height: 47)
                .foregroundStyle(Colors.redAccent)
                .padding(.bottom, 28)

            Text("Access to photos & videos denied.")
                .bold()
                .padding(.bottom, 5)

            Text("Adjust your settings and try again")
                .padding(.bottom, 20)

            Button {
                openSettings()
            } label: {
                Text("Go to settings")
                    .font(.customFont(weight: .regular, style: .callout))
                    .frame(width: 176, height: 40, alignment: .center)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(lineWidth: 1)

                    )
            }
        }
        .font(.customFont(weight: .regular, style: .body))
        .foregroundStyle(Colors.whitePrimary)
        .padding(.top, 28)
    }

    private func photoSelectionIndicatorView(for asset: PHAsset) -> some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: 1)

            if let index = selectedPhotoAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
                Text("\(index + 1)")
                    .font(.customFont(weight: .regular, size: .footnote))
            }
        }
        .foregroundStyle(Colors.whitePrimary)
    }

    private func togglePhotoSelection(for asset: PHAsset) {
        withAnimation {
            if let index = selectedPhotoAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
                selectedPhotoAssets.remove(at: index)
            } else {
                selectedPhotoAssets.append(asset)
            }
        }
    }
}

// MARK: - Video post

extension PostCreationView {
    private var videoPreviewView: some View {
        Group {
            if let selectedLongVideoAsset {
                VideoThumbnail(asset: selectedLongVideoAsset)
                    .id(selectedLongVideoAsset.localIdentifier)
                    .scaledToFit()
                    .clipped()
            } else {
                if let latestAsset = photoLibrary.longVideoAssets.first {
                    VideoThumbnail(asset: latestAsset)
                        .scaledToFit()
                        .clipped()
                } else {
                    ProgressView()
                        .controlSize(.extraLarge)
                }
            }
        }
        .frame(width: getRect().width, height: getRect().height / 2.2)
        .background(Gradients.blackHover)
    }

    @ViewBuilder
    private var videoPostGuideView: some View {
        Group {
            switch viewModel.selectedVideoType {
                case .none:
                    videoPostTypeSelectionView
                case .short:
                    shortVideoChosingGuideView
                case .shortAndLong:
                    switch viewModel.currentShortAndLongVideoSelection {
                        case .short:
                            shortVideoChosingGuideView
                        case .long:
                            longVideoChosingGuideView
                    }
            }
        }
        .font(.customFont(weight: .regular, style: .callout))
        .padding(.horizontal, 20)
    }

    private var videoPostTypeSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose the format of the video")

            Button {
                viewModel.selectedVideoType = .short
            } label: {
                HStack(spacing: 20) {
                    Text("Short")
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(Colors.whitePrimary, lineWidth: 2)
                        .frame(width: 11, height: 21)
                    Icons.arrowDownNormal
                        .iconSize(height: 15)
                        .foregroundStyle(Colors.whitePrimary)
                        .rotationEffect(.degrees(270))
                }
                .foregroundStyle(Colors.whitePrimary)
                .font(.customFont(weight: .regular, style: .footnote))
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(Colors.shortVideo)
            }
            .clipShape(RoundedRectangle(cornerRadius: 73))

//            Button {
//                viewModel.selectedVideoType = .shortAndLong
//            } label: {
//                HStack(spacing: 10) {
//                    Text("Short + Long")
//                    Spacer()
//                    RoundedRectangle(cornerRadius: 2)
//                        .strokeBorder(Color.white, lineWidth: 2)
//                        .frame(width: 11, height: 21)
//                    Text("+")
//                    RoundedRectangle(cornerRadius: 2)
//                        .strokeBorder(Color.white, lineWidth: 2)
//                        .frame(width: 29, height: 15)
//                    Icons.arrowDownNormal
//                        .iconSize(height: 15)
//                        .foregroundStyle(Color.white)
//                        .rotationEffect(.degrees(270))
//                        .padding(.leading, 10)
//                }
//                .foregroundStyle(Color.white)
//                .font(.customFont(weight: .regular, style: .footnote))
//                .padding(.vertical, 16)
//                .padding(.horizontal, 20)
//                .frame(maxWidth: .infinity)
//                .background(Colors.blueLight)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 73))
        }
        .frame(height: getRect().height / 2.2)
    }

    private var shortVideoChosingGuideView: some View {
        HStack(spacing: 20) {
            Text("Choose Short video")
            Spacer()
        }
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(weight: .regular, style: .footnote))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Colors.blueLight)
        .clipShape(RoundedRectangle(cornerRadius: 73))
    }

    private var longVideoChosingGuideView: some View {
        HStack(spacing: 10) {
            Text("Choose Full video")
            Spacer()
        }
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(weight: .regular, style: .footnote))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Colors.blueLight)
        .clipShape(RoundedRectangle(cornerRadius: 73))
    }

    @ViewBuilder
    private var shortVideosScrollView: some View {
        if photoLibrary.photoAccessGranted {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(photoLibrary.longVideoAssets, id: \.localIdentifier) { asset in
                    GeometryReader { proxy in
                        PhotoThumbnail(
                            asset: asset,
                            size: CGSize(width: 300, height: 300)
                        )
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .onTapGesture {
                            toggleShortVideoSelection(for: asset)
                        }
                    }
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                    .ifCondition(selectedShortVideoAsset?.localIdentifier != asset.localIdentifier) {
                        $0.overlay(alignment: .bottomLeading) {
                            Text("\(asset.duration.stringFromTimeInterval())")
                                .font(.footnote)
                                .foregroundStyle(Colors.whitePrimary)
//                                .font(.customFont(weight: .regular, style: .caption))
                                .offset(x: 5, y: -5)
                                .allowsHitTesting(false)
                        }
                    }
                    .ifCondition(selectedShortVideoAsset?.localIdentifier == asset.localIdentifier) {
                        $0.overlay {
                            Color.black.opacity(0.5)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        } else {
            photoAccessDeniedView
        }
    }

    private func toggleShortVideoSelection(for asset: PHAsset) {
        withAnimation {
            if let selectedShortVideoAsset,
               selectedShortVideoAsset.localIdentifier == asset.localIdentifier
            {
                self.selectedShortVideoAsset = nil
                self.selectedShortVideoURL = nil
            } else {
                selectedShortVideoAsset = asset
                DispatchQueue.main.async {
                    asset.getURL(completionHandler: { responseURL in
                        self.selectedShortVideoURL = responseURL
                    })
                }
            }
        }
    }

    @ViewBuilder
    private var longVideosScrollView: some View {
        if photoLibrary.photoAccessGranted {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(photoLibrary.longVideoAssets, id: \.localIdentifier) { asset in
                    GeometryReader { proxy in
                        PhotoThumbnail(
                            asset: asset,
                            size: CGSize(width: 300, height: 300)
                        )
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .onTapGesture {
                            toggleLongVideoSelection(for: asset)
                        }
                    }
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                    .ifCondition(selectedShortVideoAsset?.localIdentifier != asset.localIdentifier) {
                        $0.overlay(alignment: .bottomLeading) {
                            Text("\(asset.duration.stringFromTimeInterval())")
                                .font(.footnote)
                                .foregroundStyle(Colors.whitePrimary)
//                                .font(.customFont(weight: .regular, style: .caption))
                                .offset(x: 5, y: -5)
                                .allowsHitTesting(false)
                        }
                    }
                    .ifCondition(selectedLongVideoAsset?.localIdentifier == asset.localIdentifier) {
                        $0.overlay {
                            Color.black.opacity(0.5)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        } else {
            photoAccessDeniedView
        }
    }

    private func toggleLongVideoSelection(for asset: PHAsset) {
        withAnimation {
            if let selectedLongVideoAsset,
               selectedLongVideoAsset.localIdentifier == asset.localIdentifier
            {
                self.selectedLongVideoAsset = nil
                self.selectedLongVideoURL = nil
            } else {
                selectedLongVideoAsset = asset
                DispatchQueue.main.async {
                    asset.getURL(completionHandler: { responseURL in
                        self.selectedLongVideoURL = responseURL
                    })
                }
            }
        }
    }
}

// MARK: - Audio Posts

extension PostCreationView {
    private var audioPostButtonsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose audio file and cover image")

            HStack(spacing: 10) {
                Button {
                    isDocumentPickerPresented = true
                } label: {
                    HStack(spacing: 20) {
                        Text("Select audio")
                        Spacer()
                        Icons.arrowDownNormal
                            .iconSize(height: 15)
                            .foregroundStyle(Colors.whitePrimary)
                            .rotationEffect(.degrees(270))
                    }
                    .foregroundStyle(Colors.whitePrimary)
                    .font(.customFont(weight: .regular, style: .footnote))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shortVideo)
                    .clipShape(RoundedRectangle(cornerRadius: 73))
                }
                .fileImporter(
                    isPresented: $isDocumentPickerPresented,
                    allowedContentTypes: [UTType.mp3],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let selectedURL = try result.get().first
                        guard let url = selectedURL else { return }

                        // Start accessing the security-scoped resource
                        if url.startAccessingSecurityScopedResource() {
                            defer { url.stopAccessingSecurityScopedResource() }

                            // Create a local copy in the app's directory
                            let localURL = try FileManager.default.copyToAppDirectory(from: url)
                            selectedAudioURL = localURL
                        } else {
                            throw CocoaError(.fileReadNoPermission)
                        }
                    } catch {
                        print("Error accessing file: \(error.localizedDescription)")
                    }
                }

                if selectedAudioURL != nil {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Colors.passwordBarsGreen)
                        .font(.title3.bold())
                }
            }

            HStack(spacing: 10) {
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 20) {
                        Text("Select cover image")
                        Spacer()
                        Icons.arrowDownNormal
                            .iconSize(height: 15)
                            .foregroundStyle(Colors.whitePrimary)
                            .rotationEffect(.degrees(270))
                    }
                    .foregroundStyle(Colors.whitePrimary)
                    .font(.customFont(weight: .regular, style: .footnote))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(Colors.blueLight)
                    .clipShape(RoundedRectangle(cornerRadius: 73))
                }
                .onChange(of: selectedPhoto) {
                    Task {
                        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedCoverAsset = uiImage
                        }
                    }
                }

                if selectedPhoto != nil {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Colors.passwordBarsGreen)
                        .font(.title3.bold())
                }
            }
        }
        .frame(height: getRect().height / 2.2)
        .font(.customFont(weight: .regular, style: .callout))
        .padding(.horizontal, 20)
    }
}

#Preview {
    PostCreationView()
        .environmentObject(AccountManager.shared)
        .environmentObject(APIServiceManager(.mock))
}


extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

// MARK: - FileManager Extension
extension FileManager {
    func copyToAppDirectory(from sourceURL: URL) throws -> URL {
        let appDirectory = try url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destinationURL = appDirectory.appendingPathComponent(sourceURL.lastPathComponent)

        // Remove existing file if it exists
        if fileExists(atPath: destinationURL.path) {
            try removeItem(at: destinationURL)
        }

        try copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}
