//
//  SettingsView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 10.03.25.
//

import SwiftUI
import Environment
import DesignSystem
import PhotosUI
import Analytics

public struct SettingsView: View {
    @frozen
    public enum Field {
        case bio
        case email
        case username
    }

    @Environment(\.openURL) private var openURL
    @Environment(\.analytics) private var analytics

    @EnvironmentObject private var apiManager: APIServiceManager
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var audioManager: AudioSessionManager
    @EnvironmentObject private var router: Router

    @StateObject private var viewModel = SettingsViewModel()

    @FocusState private var focusedField: Field?

    @State private var isImagePickerPresented: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @State private var textFieldTitleWidth: CGFloat?

    public init() {}

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Settings")
        } content: {
            ScrollView {
                if let user = accountManager.user {
                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            ProfileAvatarView(url: user.imageURL, name: user.username, config: .settings, ignoreCache: true)
                            Spacer()
                            Button {
                                isImagePickerPresented = true
                            } label: {
                                Text("Change photo")
                                    .padding(20)
                                    .background(Colors.inactiveDark)
                                    .cornerRadius(24)
                            }
                            Spacer()
                                .frame(width: 10)
                            Icons.camera
                                .iconSize(height: 23)
                        }

                        HStack(alignment: .top, spacing: 20) {
                            Text("Description")
                                .opacity(0.5)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onAppear {
                                                textFieldTitleWidth = proxy.size.width
                                            }
                                    }
                                )

                            VStack(spacing: 10) {
                                TextField(text: $viewModel.bio, axis: .vertical) {
                                    Text("Write a description to your profile...")
                                        .opacity(0.5)
                                }
                                .focused($focusedField, equals: .bio)
                                .submitLabel(.done)
                                .lineLimit(5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity)

                                HStack(spacing: 10) {
                                    Group {
                                        switch viewModel.bioState {
                                            case .loading:
                                                ProgressView()
                                                    .controlSize(.small)
                                            case .success:
                                                Icons.checkmark
                                                    .iconSize(height: 13)
                                            case .failure:
                                                Icons.x
                                                    .iconSize(height: 13)
                                        }
                                    }

                                    Text("\(viewModel.bio.count)/500")
                                        .opacity(0.5)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Colors.inactiveDark)
                        }

                        HStack(spacing: 15) {
                            Button {
                                router.navigate(to: RouterDestination.changePassword)
                            } label: {
                                Text("Change password")
                                    .font(.customFont(weight: .regular, style: .footnote))
                                    .foregroundStyle(Colors.blackDark)
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .foregroundStyle(Colors.whitePrimary)
                                    }
                            }

                            Button {
                                router.navigate(to: RouterDestination.changeEmail)
                            } label: {
                                Text("Change e-mail")
                                    .font(.customFont(weight: .regular, style: .footnote))
                                    .foregroundStyle(Colors.blackDark)
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .foregroundStyle(Colors.whitePrimary)
                                    }
                            }

                            Button {
                                router.navigate(to: RouterDestination.changeUsername)
                            } label: {
                                Text("Change username")
                                    .font(.customFont(weight: .regular, style: .footnote))
                                    .foregroundStyle(Colors.blackDark)
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24)
                                            .foregroundStyle(Colors.whitePrimary)
                                    }
                            }
                        }

                        blockedUsersButton

                        HStack(spacing: 15) {
                            deactivateProfileButton
                            
                            logoutButton
                        }

                        shareFeedbackButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 41)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .font(.customFont(weight: .regular, style: .footnote))
            .foregroundStyle(Colors.whitePrimary)
            .overlay(alignment: .bottom) {
                howPeerWorksButton
            }
        }
        .background {
            Colors.textActive
                .ignoresSafeArea(.all)
        }
        .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
            Task {
                await viewModel.fetchBio(url: viewModel.bioUrl)
            }
        }
        .onChange(of: selectedPhotoItem) {
            loadImage()
        }
        .onChange(of: viewModel.bio) {
            guard focusedField == .bio else { return }
            guard viewModel.bio.contains("\n") else { return }
            focusedField = nil
            viewModel.bio = viewModel.bio.replacing("\n", with: "")
            Task {
                do {
                    try await viewModel.updateBio()
                    showPopup(text: "Successfully updated bio.")
                } catch {
                    showPopup(text: "Failed to update bio.")
                }
                self.selectedPhotoItem = nil
            }
        }
        .trackScreen(AppScreen.settings)
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
            }
        }
    }

    @ViewBuilder
    private var blockedUsersButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Blocked users")

        StateButton(config: config) {
            router.navigate(to: RouterDestination.blockedUsers)
        }
    }

    @ViewBuilder
    private var deactivateProfileButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .alert, title: "Delete profile")

        StateButton(config: config) {
            SystemPopupManager.shared.presentPopup(.deactivateAccount) {
                router.navigate(to: RouterDestination.deleteAccount)
            }
        }
    }

    @ViewBuilder
    private var logoutButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .alert, title: "Logout")

        StateButton(config: config) {
            SystemPopupManager.shared.presentPopup(.logout) {
                audioManager.stop()
                analytics.track(AuthEvent.logout)
                analytics.resetUserID()
                authManager.logout()
            }
        }
    }

    @ViewBuilder
    private var shareFeedbackButton: some View {
        let config = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Share feedback", icon: Icons.bubbleDots, iconPlacement: .trailing)

        StateButton(config: config) {
            openURL(URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeTRecbfUTKmpYHSaE7bSawEagUpkOPagJtLqZdsec659HaGw/viewform")!)
        }
    }

    private var howPeerWorksButton: some View {
        Button {
            PopupManager.shared.isShowingOnboarding = true
        } label: {
            HStack(spacing: 20) {
                Text("How **_peer_** works")

                Text("?")
                    .overlay {
                        Circle()
                            .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                            .frame(width: 24, height: 24)
                    }
            }
            .font(.custom(.bodyRegular))
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundStyle(Colors.blackDark)
                    
                    RoundedRectangle(cornerRadius: 50)
                        .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                }
            }
            .contentShape(.rect)
        }
    }
}
