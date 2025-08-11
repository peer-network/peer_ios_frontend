//
//  CommentError.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import Models
import Foundation

enum CommentError: Error {
    case alreadyLiked
    case alreadyReported
    case ownLike
    case ownReport
    case freeCommentsLimitReached
    case serverError(APIError)

    var localizedDescription: String {
        switch self {
            case .alreadyLiked:
                return NSLocalizedString(
                    "The comment is already liked.",
                    comment: "Already liked"
                )
            case .ownLike:
                return NSLocalizedString(
                    "You can not like your own comment.",
                    comment: "Own comment like"
                )
            case .freeCommentsLimitReached:
                return NSLocalizedString(
                    "You have reached your daily free comments limit.",
                    comment: "Daily free comments limit reached"
                )
            case .serverError:
                return NSLocalizedString(
                    "Failed to perform the action. Please try again.",
                    comment: "Unknown server error"
                )
            case .alreadyReported:
                return NSLocalizedString(
                    "The comment is already reported.",
                    comment: "Already reported"
                )
            case .ownReport:
                return NSLocalizedString(
                    "You can not report your own comment.",
                    comment: "Own comment report"
                )
        }
    }
}
