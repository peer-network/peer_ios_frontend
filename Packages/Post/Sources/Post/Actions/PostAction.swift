//
//  PostAction.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem

@MainActor
enum PostAction {
    case like, dislike, comment, views, menu

    func getIcon(viewModel: PostViewModel) -> Image {
        switch self {
            case .like:
                viewModel.isLiked ? Icons.heartFill : Icons.heart
            case .dislike:
                viewModel.isDisliked ? Icons.heartBrokeFill : Icons.heartBroke
            case .comment:
                Icons.bubble
            case .views:
                Icons.eyeCircled
            case .menu:
                Icons.ellipsis
        }
    }

    func getAmount(viewModel: PostViewModel) -> Int? {
        switch self {
            case .like:
                return viewModel.amountLikes
            case .dislike:
                return viewModel.amountDislikes
            case .comment:
                return viewModel.amountComments
            case .views:
                return viewModel.amountViews
            case .menu:
                return nil
        }
    }

    func getDefaultColor() -> Color {
        switch self {
            case .like, .dislike, .comment, .menu:
                return Colors.whitePrimary
            case .views:
                return Colors.whiteSecondary
        }
    }

    var tintColor: Color? {
        switch self {
            case .like:
                Colors.redAccent
            case .dislike:
                Colors.redAccent
            case .comment, .views, .menu:
                nil
        }
    }

    func isOn(viewModel: PostViewModel) -> Bool {
        switch self {
            case .like:
                viewModel.isLiked
            case .dislike:
                viewModel.isDisliked
            case .menu, .comment, .views:
                false
        }
    }
}
