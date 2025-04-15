//
//  FullScreenPostView.swift
//  FeedNew
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

public struct FullScreenPostView: View {
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var apiManager: APIServiceManager

    private let post: Post

    public init(post: Post) {
        self.post = post
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Post")
        } content: {
            PostView(postVM: PostViewModel(post: post))
        }
        .background(Colors.textActive)
    }
}
