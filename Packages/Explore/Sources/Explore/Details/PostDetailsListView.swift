//
//  PostDetailsListView.swift
//  Explore
//
//  Created by Artem Vasin on 21.07.25.
//

//import SwiftUI
//import FeedList
//
//@available(iOS 18.0, *)
//public struct PostDetailsListView<Fetcher>: View where Fetcher: PostsFetcher {
//    private let fetcher: Fetcher
//    private let postID: String
//    private let animation: Namespace.ID
//
//    @State private var scrollID: UUID?
//
//    public init(fetcher: Fetcher, postID: String, animation: Namespace.ID) {
//        self.fetcher = fetcher
//        self.postID = postID
//        self.animation = animation
//    }
//
//    public var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 20) {
//                PostsListView(fetcher: fetcher, displayType: .list, showFollowButton: true)
//            }
//            .padding(.vertical, 10)
//            .scrollTargetLayout()
//        }
//        .scrollPosition(id: $scrollID)
//        .scrollIndicators(.hidden)
//        .navigationTransition(.zoom(sourceID: postID, in: animation))
//    }
//}
