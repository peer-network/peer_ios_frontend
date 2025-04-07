//
//  PostAction.swift
//  FeedNew
//
//  Created by Артем Васин on 31.01.25.
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
    
    func getDefaultColor(isBackgroundWhite: Bool) -> Color {
        switch self {
            case .like, .dislike, .comment, .menu:
                return isBackgroundWhite ? Colors.textActive : Colors.whitePrimary
            case .views:
                return isBackgroundWhite ? Colors.textSuggestions : Colors.whiteSecondary
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
