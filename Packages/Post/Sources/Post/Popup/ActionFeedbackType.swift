//
//  ActionFeedbackType.swift
//  Post
//
//  Created by Artem Vasin on 13.06.25.
//

enum ActionFeedbackType {
    case freeLikeConfirmaion
    case freeCommentConfirmaion

    case noFreeLikes
    case noFreeComments

    case noTokensForLike
    case noTokensForComment
    case noTokensForDislike

    var priceInTokens: Int {
        switch self {
            case .noFreeComments, .noTokensForComment:
                return 1
            case .noFreeLikes, .noTokensForLike:
                return 1
            case .noTokensForDislike:
                return 5
            case .freeLikeConfirmaion, .freeCommentConfirmaion:
                return 0
        }
    }
}
