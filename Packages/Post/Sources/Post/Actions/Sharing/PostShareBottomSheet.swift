//
//  PostShareBottomSheet.swift
//  Post
//
//  Created by Artem Vasin on 24.08.25.
//

import SwiftUI
import Models
import DesignSystem

struct PostShareBottomSheet: View {
    private let post: Post

    public init(post: Post) {
        self.post = post
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Share post")

            HStack(spacing: 20) {
                StateButton(config: .init(buttonSize: .large, buttonType: .teritary, title: "Copy link", icon: Icons.copy, iconPlacement: .leading)) {
                    //
                }

                StateButton(config: .init(buttonSize: .large, buttonType: .teritary, title: "Share via", icon: Icons.shareVia, iconPlacement: .leading)) {
                    //
                }
            }
        }
        .padding(.top, 10)
    }
}
