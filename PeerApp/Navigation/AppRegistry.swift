//
//  AppRegistry.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Environment
import ProfileNew
import DesignSystem
import FeedNew
import Models
import LinkPresentation
import Explore
import VersionHistory
import Chat
import Wallet
import Post

extension View {
    func withAppRouter() -> some View {
        navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
                case .accountDetail(let id):
                    if #available(iOS 18, *) {
                        ProfilePageView(userId: id)
                            .toolbar(.hidden, for: .navigationBar)
                    } else {
                        ProfileView(userId: id)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                case .hashTag(let tag):
                    ExploreView(searchTag: tag)
                        .toolbar(.hidden, for: .navigationBar)
                case .postDetailsWithPost(let post):
                    FullScreenPostView(postVM: PostViewModel(post: post))
                        .toolbar(.hidden, for: .navigationBar)
                case .settings:
                    SettingsView()
                        .toolbar(.hidden, for: .navigationBar)
                case .versionHistory:
                    VersionHistoryView()
                        .toolbar(.hidden, for: .navigationBar)
                case .chat:
                    ChatView()
                        .toolbar(.hidden, for: .navigationBar)
                case .transfer(let recipient, let amount):
                    TransferPageView(recipient: recipient, amount: amount)
                        .toolbar(.hidden, for: .navigationBar)
                case .changePassword:
                    EditPasswordView { newPassword, currentPassword in
                        let apiManager = APIServiceManager()
                        let result = await apiManager.apiService.updatePassword(password: newPassword, currentPassword: currentPassword)
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .changeEmail:
                    EditEmailView { newEmail, currentPassword in
                        let apiManager = APIServiceManager()
                        let result = await apiManager.apiService.updateEmail(email: newEmail, currentPassword: currentPassword)
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .changeUsername:
                    EditUsernameView { newUsername, currentPassword in
                        let apiManager = APIServiceManager()
                        let result = await apiManager.apiService.updateUsername(username: newUsername, currentPassword: currentPassword)
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .referralProgram:
                    ReferralPageView()
                        .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    func withSheetDestinations(sheetDestinations: Binding<SheetDestination?>) -> some View {
        sheet(item: sheetDestinations) { destination in
            //TODO: should be injected, not created here
            let apiManager = APIServiceManager()
            
            switch destination {
                case .following(let userId):
                    ProfilesSheetView(type: .following, fetcher: RelationsViewModel(userId: userId, apiService: apiManager.apiService))
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(24)
                        .presentationBackground(.ultraThinMaterial)
                        .presentationDetents([.fraction(0.75), .large])
                        .presentationContentInteraction(.resizes)
                        .withEnvironments()
                case .followers(let userId):
                    ProfilesSheetView(type: .followers, fetcher: RelationsViewModel(userId: userId, apiService: apiManager.apiService))
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(24)
                        .presentationBackground(.ultraThinMaterial)
                        .presentationDetents([.fraction(0.75), .large])
                        .presentationContentInteraction(.resizes)
                        .withEnvironments()
                case .friends(let userId):
                    ProfilesSheetView(type: .friends, fetcher: RelationsViewModel(userId: userId, apiService: apiManager.apiService))
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(24)
                        .presentationBackground(.ultraThinMaterial)
                        .presentationDetents([.fraction(0.75), .large])
                        .presentationContentInteraction(.resizes)
                        .withEnvironments()
//                case .comments(postVM: PostViewModel):
//                    CommentsView(post: post)
//                        .presentationDragIndicator(.hidden)
//                        .presentationCornerRadius(24)
//                        .ifCondition(!isBackgroundWhite) {
//                            $0.presentationBackground(.ultraThinMaterial)
//                        }
//                        .ifCondition(isBackgroundWhite) {
//                            $0.presentationBackground(Colors.whitePrimary)
//                        }
//                        .presentationDetents([.fraction(0.75), .large])
//                        .presentationContentInteraction(.resizes)
//                        .environment(\.isBackgroundWhite, isBackgroundWhite ? true : false)
//                        .withEnvironments()
                case .shareImage(let image, let post):
                    ActivityView(image: image, post: post)
                        .withEnvironments()
            }
        }
    }

    func withEnvironments() -> some View {
        environmentObject(AccountManager.shared)
            .environmentObject(QuickLook.shared)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let image: UIImage
    let post: Post

    class LinkDelegate: NSObject, UIActivityItemSource {
        let image: UIImage
        let post: Post

        init(image: UIImage, post: Post) {
            self.image = image
            self.post = post
        }

        func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
            let imageProvider = NSItemProvider(object: image)
            let metadata = LPLinkMetadata()
            metadata.imageProvider = imageProvider
            metadata.title = post.title
            return metadata
        }

        func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
            image
        }

        func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any?
        {
            nil
        }
    }

    func makeUIViewController(context _: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image, LinkDelegate(image: image, post: post)], applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ActivityView>) {}
}
