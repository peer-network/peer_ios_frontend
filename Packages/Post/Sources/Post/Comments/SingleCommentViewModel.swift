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
public final class SingleCommentViewModel: ObservableObject {
    unowned var apiService: APIService!

    let comment: Comment

    @Published public private(set) var isLiked: Bool
    @Published public private(set) var amountLikes: Int
    @Published public private(set) var attributedContent: AttributedString?

    // Comment likes properties
    @frozen
    public enum LikesState {
        case loading
        case display
        case error(Error)
    }
    @Published private(set) var likesState = LikesState.loading
    @Published private(set) var likedBy: [RowUser] = []
    private var likesFetchTask: Task<Void, Never>?
    private var currentLikesOffset: Int = 0
    private(set) var hasMoreLikes: Bool = true

    public init(comment: Comment) {
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

// MARK: - Comment Likes

extension SingleCommentViewModel {
    public func fetchLikes(reset: Bool) {
        if let existingTask = likesFetchTask, !existingTask.isCancelled {
            existingTask.cancel()
        }

        if reset {
            likedBy.removeAll()
            currentLikesOffset = 0
            hasMoreLikes = true
        }

        if likedBy.isEmpty {
            likesState = .loading
        }

        likesFetchTask = Task {
            do {
                let result = await apiService.getCommentInteractions(with: comment.id, after: currentLikesOffset)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedUsers):
                        await MainActor.run {
                            likedBy.append(contentsOf: fetchedUsers)

                            if fetchedUsers.count != Constants.postInteractionsLimit {
                                hasMoreLikes = false
                            } else {
                                currentLikesOffset += Constants.postInteractionsLimit
                            }
                            likesState = .display
                        }
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                await MainActor.run {
                    likesState = .error(error)
                }
            }

            likesFetchTask = nil
        }
    }
}
