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

public struct SettingsView: View {
    @frozen
    public enum Field {
        case bio
        case email
        case username
    }

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
                            ProfileAvatarView(url: user.imageURL, name: user.username, config: .settings)
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

//                        HStack(alignment: .top, spacing: 20) {
//                            Text("E-mail")
//                                .opacity(0.5)
//                                .frame(width: textFieldTitleWidth, alignment: .leading)
//
//                            VStack(spacing: 10) {
//                                TextField(text: $viewModel.email) {
//                                    Text("me@me")
//                                        .opacity(0.5)
//                                }
//                                .focused($focusedField, equals: .email)
//                                .submitLabel(.done)
//                                .lineLimit(1)
//                                .multilineTextAlignment(.leading)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                        }
//                        .padding(20)
//                        .background {
//                            RoundedRectangle(cornerRadius: 20)
//                                .foregroundStyle(Colors.inactiveDark)
//                        }

//                        HStack(alignment: .top, spacing: 20) {
//                            Text("Username")
//                                .opacity(0.5)
//                                .frame(width: textFieldTitleWidth, alignment: .leading)
//
//                            VStack(spacing: 10) {
//                                TextField(text: $viewModel.username, axis: .vertical) {
//                                    Text("me")
//                                        .opacity(0.5)
//                                }
//                                .focused($focusedField, equals: .username)
//                                .submitLabel(.done)
//                                .lineLimit(1)
//                                .multilineTextAlignment(.leading)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                        }
//                        .padding(20)
//                        .background {
//                            RoundedRectangle(cornerRadius: 20)
//                                .foregroundStyle(Colors.inactiveDark)
//                        }

                        HStack(spacing: 10) {
                            logoutButton
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .font(.customFont(weight: .regular, style: .footnote))
            .foregroundStyle(Colors.whitePrimary)
        }
        .background {
            Colors.textActive
                .ignoresSafeArea(.all)
        }
        .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
        .onAppear {
            viewModel.apiService = apiManager.apiService
            Task {
                await viewModel.fetchBio(url: viewModel.bioUrl)
            }
        }
        .onChange(of: selectedPhotoItem) {
            loadImage()
        }
//        .onSubmit {
//            focusedField = nil
//            switch focusedField {
//                case .bio:
//                    Task {
//                        do {
//                            try await viewModel.updateBio()
//                            showPopup(text: "Successfully updated bio.")
//                        } catch {
//                            showPopup(text: "Failed to update bio.")
//                        }
//                    }
//                case .email:
//                    break
//                case .username:
//                    break
//                case .none:
//                    break
//            }
//        }
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

    private var logoutButton: some View {
        Button {
            audioManager.stop()
            authManager.logout()
        } label: {
            Text("Logout")
                .padding(20)
                .foregroundStyle(Colors.redAccent)
                .font(.customFont(weight: .regular, style: .footnote))
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Colors.redAccent, lineWidth: 1)
                }
        }
    }
}
