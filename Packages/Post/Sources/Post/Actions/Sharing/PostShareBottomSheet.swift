//
//  PostShareBottomSheet.swift
//  Post
//
//  Created by Artem Vasin on 24.08.25.
//

import SwiftUI
import Models
import DesignSystem
import Environment

public struct PostShareBottomSheet: View {
    @ObservedObject var viewModel: PostViewModel

    public init(viewModel: PostViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Capsule()
                .frame(width: 44.5, height: 1)
                .foregroundStyle(Colors.whitePrimary)

            Text("Share post")
                .font(.customFont(weight: .bold, size: .title))
                .lineLimit(1)
                .foregroundStyle(Colors.whitePrimary)

            HStack(spacing: 20) {
                StateButton(config: .init(buttonSize: .large, buttonType: .teritary, title: "Copy link", icon: Icons.copy, iconPlacement: .leading))
                {
                    HapticManager.shared.fireHaptic(.buttonPress)
                    UIPasteboard.general.string = viewModel.post.url
                    viewModel.showShareSheet = false
                    showPopup(text: "Link copied!", icon: Icons.copyDone)
                }

                PostShareLinkView(post: viewModel.post) {
                    StateButton(config: .init(buttonSize: .large, buttonType: .teritary, title: "Share via", icon: Icons.shareVia, iconPlacement: .leading)) {
                        // Nothing here, it is passed as a regular view
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
