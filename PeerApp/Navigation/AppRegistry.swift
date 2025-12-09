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
import Wallet
import Post
import TokenKeychainManager

extension View {
    func withAppRouter(appState: AppState, apiServiceManager: APIServiceManager, router: Router) -> some View {
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
                case .postDetailsWithPostId(let id):
                    FullScreenPostView(postId: id)
                        .toolbar(.hidden, for: .navigationBar)
                case .settings:
                    SettingsView()
                        .toolbar(.hidden, for: .navigationBar)
                case .versionHistory:
                    VersionHistoryView()
                        .toolbar(.hidden, for: .navigationBar)
                case .transfer(let recipient, let amount):
                    TransferPageView(recipient: recipient, amount: amount)
                        .toolbar(.hidden, for: .navigationBar)
                case .changePassword:
                    EditPasswordView { newPassword, currentPassword in
#if DEBUG
                        let testConfig = APIConfiguration(endpoint: .custom)
                        let apiManager = APIServiceManager(.normal(config: testConfig))
#else
                        let apiManager = APIServiceManager()
#endif
                        let result = await apiManager.apiService.updatePassword(password: newPassword, currentPassword: currentPassword)
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .changeEmail:
                    EditEmailView { newEmail, currentPassword in
#if DEBUG
                        let testConfig = APIConfiguration(endpoint: .custom)
                        let apiManager = APIServiceManager(.normal(config: testConfig))
#else
                        let apiManager = APIServiceManager()
#endif
                        let result = await apiManager.apiService.updateEmail(email: newEmail, currentPassword: currentPassword)
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .changeUsername:
                    EditUsernameView { newUsername, currentPassword in
#if DEBUG
                        let testConfig = APIConfiguration(endpoint: .custom)
                        let apiManager = APIServiceManager(.normal(config: testConfig))
#else
                        let apiManager = APIServiceManager()
#endif
                        let result = await apiManager.apiService.updateUsername(username: newUsername, currentPassword: currentPassword)
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .deleteAccount:
                    DeleteAccountView { currentPassword in
#if DEBUG
                        let testConfig = APIConfiguration(endpoint: .custom)
                        let apiManager = APIServiceManager(.normal(config: testConfig))
#else
                        let apiManager = APIServiceManager()
#endif
                        let audioManager = AudioSessionManager.shared

                        let result = await apiManager.apiService.deleteAccount(password: currentPassword)
                        if case .success = result {
                            audioManager.stop()
                            TokenKeychainManager.shared.removeCredentials()
                            exit(0)
                        }
                        return result
                    }
                    .toolbar(.hidden, for: .navigationBar)
                case .referralProgram:
                    ReferralPageView()
                        .toolbar(.hidden, for: .navigationBar)
                case .blockedUsers:
                    BlockedUsersPageView()
                        .toolbar(.hidden, for: .navigationBar)
                case .commentLikes(let comment):
                    CommentLikesListView(comment: comment)
                        .toolbar(.hidden, for: .navigationBar)
                case .promotePost(let flowID, let step):
                    PromotePostStepView(flowID: flowID, step: step)
                           .toolbar(.hidden, for: .navigationBar)
                case .adsHistoryOverview:
                    AdHistoryOverviewView(viewModel: .init(apiService: apiServiceManager.apiService))
                        .toolbar(.hidden, for: .navigationBar)
                case .adsHistoryDetails(let ad):
                    AdHistoryAdDetailView(ad: ad)
                        .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    func withSheetDestinations(sheetDestinations: Binding<SheetDestination?>, apiServiceManager: APIServiceManager) -> some View {
        sheet(item: sheetDestinations) { destination in
            switch destination {
                case .following(let userId):
                    ProfilesSheetView(type: .following, fetcher: RelationsViewModel(userId: userId, apiService: apiServiceManager.apiService))
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(24)
                        .presentationBackground(Colors.blackDark)
                        .presentationDetents([.fraction(0.75), .large])
                        .presentationContentInteraction(.resizes)
                        .withEnvironments()
                case .followers(let userId):
                    ProfilesSheetView(type: .followers, fetcher: RelationsViewModel(userId: userId, apiService: apiServiceManager.apiService))
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(24)
                        .presentationBackground(Colors.blackDark)
                        .presentationDetents([.fraction(0.75), .large])
                        .presentationContentInteraction(.resizes)
                        .withEnvironments()
                case .friends(let userId):
                    ProfilesSheetView(type: .friends, fetcher: RelationsViewModel(userId: userId, apiService: apiServiceManager.apiService))
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(24)
                        .presentationBackground(Colors.blackDark)
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
