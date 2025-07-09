//
//  SingleCommentViewModel.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import Models
import Environment

@MainActor
final class SingleCommentViewModel: ObservableObject {
    unowned var apiService: APIService!

    let comment: Comment

    @Published public private(set) var isLiked: Bool
    @Published public private(set) var amountLikes: Int
    @Published public private(set) var attributedContent: AttributedString?

    init(comment: Comment) {
        self.comment = comment

        isLiked = comment.isLiked
        amountLikes = comment.amountLikes

        attributedContent = comment.content.createAttributedString()
    }

    func likeComment() async throws {
        guard !isLiked else {
            throw CommentError.alreadyLiked
        }

        guard !AccountManager.shared.isCurrentUser(id: comment.user.id) else {
            throw CommentError.ownLike
        }

        await MainActor.run {
            withAnimation {
                isLiked = true
                amountLikes += 1
            }
        }

        do {
            let result = await apiService.likeComment(with: comment.id)

            switch result {
                case .success:
                    break
                case .failure(let apiError):
                    throw apiError
            }
        } catch {
            await MainActor.run {
                isLiked = false
                amountLikes -= 1
            }
            throw APIError.unknownError(error: error)
        }
    }

    func report() async throws {
        // FIXME: There is no way to check if the comment was already reported in the API
//        guard !isReported else {
//            throw CommentError.alreadyReported
//        }

        guard !AccountManager.shared.isCurrentUser(id: comment.user.id) else {
            throw CommentError.ownReport
        }

//        await MainActor.run {
//            isReported = true
//        }

        do {
            let result = await apiService.reportComment(with: comment.id)

            switch result {
            case .success:
                break
            case .failure(let apiError):
                throw apiError
            }
        } catch {
//            await MainActor.run {
//                isReported = false
//            }
            throw error
        }
    }
}
