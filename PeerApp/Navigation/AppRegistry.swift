//
//  AppRegistry.swift
//  PeerApp
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI
import Environment
//import Profile
import DesignSystem
//import Feed
import Models
import LinkPresentation

extension View {
    func withAppRouter() -> some View {
        navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
                case .followers(let id):
//                    ProfilesListView(mode: .followers(userId: id))
                    EmptyView()
                case .following(let id):
//                    ProfilesListView(mode: .followings(userId: id))
                    EmptyView()
                case .settingsHaptic:
                    HapticSettingsView()
                case .settingsTabs:
                    TabbarEntriesSettingsView()
                case .accountDetail(let id):
//                    ProfileView(userId: id, isCurrentUser: AccountManager.shared.isCurrentUser(id: id))
                    EmptyView()
                case .hashTag(let tag):
//                    FeedView(type: .hashTag(tag: tag))
                    EmptyView()
                case .settingsTheme:
                    DisplaySettingsView()
                case .postDetailsWithPost(let post):
                    Color.red //
                case .settingsContent:
                    ContentSettingsView()
            }
        }
    }
    
    func withSheetDestinations(sheetDestinations: Binding<SheetDestination?>) -> some View {
        sheet(item: sheetDestinations) { destination in
            switch destination {
                case .postEditor:
//                    PostEditorView()
                    EmptyView()
                        .withEnvironments()
                case .about:
                    Color.red
                        .withEnvironments()
                case .settings:
                    SettingsTab(isModal: true)
                        .withEnvironments()
                        .preferredColorScheme(Theme.shared.selectedScheme == .dark ? .dark : .light)
                case .userEditInfo(let user, let bio):
                    EmptyView()
//                    EditProfileView(user: user, bio: bio)
                        .withEnvironments()
                case .feedContentFilter:
                    NavigationSheet {
//                        FeedContentFilterView()
                        EmptyView()
                    }
                        .presentationDetents([.medium])
                        .presentationBackground(.thinMaterial)
                        .withEnvironments()
                case .reportPost(let post):
                    ReportView(post: post)
                        .withEnvironments()
                case .shareImage(let image, let post):
                    ActivityView(image: image, post: post)
                        .withEnvironments()
            }
        }
    }
    
    func withEnvironments() -> some View {
        environmentObject(UserPreferences.shared)
            .environmentObject(Theme.shared)
            .environmentObject(AccountManager.shared)
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
