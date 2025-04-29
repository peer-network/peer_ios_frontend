//
//  CommentsViewModel.swift
//  FeedNew
//
//  Created by Артем Васин on 24.02.25.
//

import SwiftUI
import Models
import Environment

enum CommentError: Error {
    case alreadyLiked
    case ownLike
    case freeCommentsLimitReached
    case serverError(APIError)

    var displayMessage: String {
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
        }
    }
}

public enum CommentsState {
    public enum PagingState {
        case hasMore, none
    }

    case loading
    case display(comments: [Comment], hasMore: CommentsState.PagingState)
    case error(error: Error)
}

@MainActor
final class CommentsViewModel: ObservableObject {
    public unowned var apiService: (any APIService)!
    
    @Published private(set) var state = CommentsState.loading

    @Published private(set) var comments: [Comment] = []

    let post: Post

    private var fetchTask: Task<Void, Never>?

    private var currentOffset: Int = 0
    private var hasMoreComments: Bool = true

    init(post: Post) {
        self.post = post
    }

    func fetchComments() {
        // Do not uncomment it until sending a new comment under posts with 0 comments adds 1 to its stats
//        if post.amountComments == 0 {
//            state = .display(comments: [], hasMore: .none)
//            return
//        }

        if let existingTask = fetchTask, !existingTask.isCancelled {
            return
        }

        fetchTask = Task {
            do {
                let result = await apiService.fetchComments(for: post.id, after: currentOffset)
                
                try Task.checkCancellation()
                
                switch result {
                case .success(let fetchedComments):
                    comments.append(contentsOf: fetchedComments)

                    if fetchedComments.count != Constants.postCommentsLimit {
                        hasMoreComments = false
                        state = .display(comments: comments, hasMore: .none)
                    } else {
                        currentOffset += Constants.postCommentsLimit
                        state = .display(comments: comments, hasMore: .hasMore)
                    }
                case .failure(let apiError):
                    throw apiError
                }
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                print(error)
                print(error.localizedDescription)
                state = .error(error: error)
            }

            // Reset fetchTask to nil when done
            fetchTask = nil
        }
    }

    func sendComment(_ text: String) async throws {
        guard AccountManager.shared.dailyFreeComments > 0 else {
            throw CommentError.freeCommentsLimitReached
        }

        let fixedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if fixedText.isEmpty {
            return
        }

        AccountManager.shared.freeCommentUsed()
        
        let result = await apiService.sendComment(for: post.id, with: fixedText)
        
        switch result {
        case .success(let createdComment):
            comments.append(createdComment)
            state = .display(comments: comments, hasMore: .none)
        case .failure(let apiError):
            throw CommentError.serverError(apiError)
        }
    }
}
