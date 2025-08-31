//
//  FullScreenPostView.swift
//  Post
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import DesignSystem
import Environment

public struct FullScreenPostView: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @State private var postVM: PostViewModel?
    private let postId: String?

    public init(postVM: PostViewModel) {
        self.postVM = postVM
        self.postId = nil
    }

    public init(postId: String) {
        self.postId = postId
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Post")
        } content: {
            if let postVM {
                ScrollView {
                    PostView(postVM: postVM, displayType: .list, showFollowButton: true)
                }
            } else {
                ProgressView()
                    .controlSize(.large)
                    .padding(.top, 100)
            }
        }
        .onFirstAppear {
            if let postId {
                Task {
                    postVM = await PostViewModel(id: postId, apiService: apiManager.apiService)
                }
            }
        }
    }
}
