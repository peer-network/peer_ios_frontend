//
//  PostActionError.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import DesignSystem

enum PostActionError: Error {
    case alreadyLiked
    case alreadyDisliked
    case alreadyReported
    case alreadyViewed

    case ownPostLike
    case ownPostDislike
    case ownPostReport
    case ownPostView

    case freeLikesLimitReached

    case serverError

    var displayMessage: String {
        switch self {
            case .alreadyLiked:
                return NSLocalizedString(
                    "The post is already liked.",
                    comment: "Already liked"
                )
            case .alreadyDisliked:
                return NSLocalizedString(
                    "The post is already disliked.",
                    comment: "Already disliked"
                )
            case .alreadyReported:
                return NSLocalizedString(
                    "The post is already reported.",
                    comment: "Already reported"
                )
            case .ownPostLike:
                return NSLocalizedString(
                    "You can not like your own post.",
                    comment: "Own post like"
                )
            case .ownPostDislike:
                return NSLocalizedString(
                    "You can not dislike your own post.",
                    comment: "Own post dislike"
                )
            case .ownPostReport:
                return NSLocalizedString(
                    "You can not report your own post.",
                    comment: "Own post report"
                )
            case .freeLikesLimitReached:
                return NSLocalizedString(
                    "You have reached your daily free likes limit.",
                    comment: "Daily free likes limit reached"
                )
            case .alreadyViewed:
                return NSLocalizedString(
                    "The post is already viewed.",
                    comment: "The post is already viewed"
                )
            case .serverError:
                return NSLocalizedString(
                    "Failed to perform the action. Please try again.",
                    comment: "Unknown server error"
                )
            case .ownPostView:
                return NSLocalizedString(
                    "You can not view your own post.",
                    comment: "Own post view"
                )
        }
    }

    var displayIcon: Image? {
        switch self {
            case .alreadyLiked:
                return Icons.heart //.foregroundStyle(Color.white)
            case .alreadyDisliked:
                return Icons.heartBroke //.foregroundStyle(Color.white))
            case .alreadyReported:
                return nil
            case .ownPostLike:
                return Icons.heart //.foregroundStyle(Color.white))
            case .ownPostDislike:
                return Icons.heartBroke //.foregroundStyle(Color.white))
            case .ownPostReport:
                return nil
            case .freeLikesLimitReached:
                return Icons.heart //.foregroundStyle(Color.white))
            case .serverError:
                return nil
            case .alreadyViewed:
                return nil
            case .ownPostView:
                return nil
        }
    }
}
