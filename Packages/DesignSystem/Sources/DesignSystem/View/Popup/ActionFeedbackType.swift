//
//  ActionFeedbackType.swift
//  Post
//
//  Created by Artem Vasin on 13.06.25.
//

import SwiftUI
import Environment

public enum ActionFeedbackType {
    case freeLikeConfirmaion
    case freeCommentConfirmaion

    case noFreeLikes
    case noFreeComments

    case dislikeConfirmaion

    case noTokensForLike(Double)
    case noTokensForComment(Double)
    case noTokensForDislike(Double)

    public var priceInTokens: Double {
        switch self {
            case .noFreeComments, .noTokensForComment:
                return 0.5
            case .noFreeLikes, .noTokensForLike:
                return 3
            case .noTokensForDislike, .dislikeConfirmaion:
                return 5
            case .freeLikeConfirmaion, .freeCommentConfirmaion:
                return 0
        }
    }

    var titleText: String {
        switch self {
            case .freeLikeConfirmaion:
                return "You’re about to spend free like!"
            case .freeCommentConfirmaion:
                return "You’re about to spend free comment!"
            case .noFreeLikes:
                return "You’re out of free likes!"
            case .noFreeComments:
                return "You’re out of free comments!"
            case .dislikeConfirmaion:
                return "Dislikes are not free!"
            case .noTokensForLike, .noTokensForComment, .noTokensForDislike:
                return "Insufficient Tokens"
        }
    }

    var titleIcon: some View {
        switch self {
            case .noFreeLikes, .freeLikeConfirmaion:
                return Icons.heartFill.iconSize(height: 19)
            case .noFreeComments, .freeCommentConfirmaion:
                return Icons.bubbleFill.iconSize(height: 23)
            case .dislikeConfirmaion:
                return Icons.heartBrokeFill.iconSize(height: 21)
            case .noTokensForComment, .noTokensForLike, .noTokensForDislike:
                return Icons.exclamationMarkTriangleBlack.iconSize(height: 20)
        }
    }

    var titleTintColor: Color {
        switch self {
            case .freeLikeConfirmaion, .freeCommentConfirmaion:
                return Colors.whitePrimary
            case .noFreeLikes, .noFreeComments, .noTokensForLike, .noTokensForComment, .noTokensForDislike, .dislikeConfirmaion:
                return Colors.redAccent
        }
    }

    var bodyText: String {
        switch self {
            case .freeLikeConfirmaion:
                return "Remaining free likes"
            case .freeCommentConfirmaion:
                return "Remaining free comments"
            case .noFreeLikes:
                return "Liking this post will cost"
            case .dislikeConfirmaion:
                return "Disliking this post will cost"
            case .noFreeComments:
                return "Commenting this post will cost"
            case .noTokensForLike:
                return "Like cost:"
            case .noTokensForComment:
                return "Comment cost:"
            case .noTokensForDislike:
                return "Dislike cost:"
        }
    }

    @MainActor
    var bodyValue: Double {
        switch self {
            case .freeLikeConfirmaion:
                return Double(AccountManager.shared.dailyFreeLikes)
            case .freeCommentConfirmaion:
                return Double(AccountManager.shared.dailyFreeComments)
            case .noFreeLikes:
                return priceInTokens
            case .noFreeComments:
                return priceInTokens
            case .dislikeConfirmaion:
                return priceInTokens
            case .noTokensForLike:
                return priceInTokens
            case .noTokensForComment:
                return priceInTokens
            case .noTokensForDislike:
                return priceInTokens
        }
    }

    var showTokensLogogInBody: Bool {
        switch self {
            case .freeLikeConfirmaion, .freeCommentConfirmaion:
                return false
            case .dislikeConfirmaion, .noFreeLikes, .noFreeComments, .noTokensForLike, .noTokensForComment, .noTokensForDislike:
                return true
        }
    }

    var confirmButtonText: String {
        switch self {
            case .noTokensForLike, .noTokensForComment, .noTokensForDislike:
                return "Earn more"
            case .freeLikeConfirmaion, .freeCommentConfirmaion, .noFreeLikes, .noFreeComments, .dislikeConfirmaion:
                return "Confirm"
        }
    }

    var currentUserBalance: Double? {
        switch self {
            case .freeLikeConfirmaion:
                return nil
            case .freeCommentConfirmaion:
                return nil
            case .noFreeLikes:
                return nil
            case .noFreeComments:
                return nil
            case .dislikeConfirmaion:
                return nil
            case .noTokensForLike(let balance):
                return balance
            case .noTokensForComment(let balance):
                return balance
            case .noTokensForDislike(let balance):
                return balance
        }
    }
}
