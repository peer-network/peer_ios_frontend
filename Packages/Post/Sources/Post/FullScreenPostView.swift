//
//  FullScreenPostView.swift
//  Post
//
//  Created by Artem Vasin on 20.05.25.
//

import SwiftUI
import DesignSystem

public struct FullScreenPostView: View {
    private let postVM: PostViewModel

    public init(postVM: PostViewModel) {
        self.postVM = postVM
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Post")
        } content: {
            ScrollView {
                PostView(postVM: postVM, displayType: .list, showFollowButton: true)
            }
        }
        .background(Colors.textActive)
    }
}
