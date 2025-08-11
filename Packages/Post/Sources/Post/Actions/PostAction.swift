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
    case like, dislike, comment, views

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
        }
    }

    func getDefaultColor() -> Color {
        switch self {
            case .like, .dislike, .comment:
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
            case .comment, .views:
                nil
        }
    }

    func isOn(viewModel: PostViewModel) -> Bool {
        switch self {
            case .like:
                viewModel.isLiked
            case .dislike:
                viewModel.isDisliked
            case .comment, .views:
                false
        }
    }

    var postInteraction: InteractionType? {
        switch self {
            case .like:
                return .likes
            case .dislike:
                return .dislikes
            case .comment:
                return nil
            case .views:
                return .views
        }
    }
}
