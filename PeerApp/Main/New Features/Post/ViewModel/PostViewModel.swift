//
//  PostViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 02.02.26.
//

import Models
import SwiftUI
import Environment
import DesignSystem

@MainActor
final class PostViewModel2: ObservableObject {
    public var apiService: APIService!

    let post: Post

    let showIllegalBlur: Bool
    @Published var showHeaderSensitiveWarning: Bool
    @Published var showSensitiveContentWarning: Bool

    @Published var showShareSheet = false

    @Published private(set) var attributedTitle: AttributedString?
    @Published private(set) var description: String?
    @Published private(set) var attributedDescription: AttributedString?

    @Published private(set) var isLiked: Bool
    @Published private(set) var isViewed: Bool
    @Published private(set) var isReported: Bool
    @Published private(set) var isDisliked: Bool

    @Published private(set) var amountLikes: Int
    @Published private(set) var amountDislikes: Int
    @Published private(set) var amountViews: Int
    @Published private(set) var amountComments: Int

    // MARK: Comments properties
    @frozen
    public enum CommentState {
        case loading
        case display
        case error(Error)
    }

    @Published private(set) var state = CommentState.loading
    private var currentCommentsOffset: Int = 0
    private(set) var hasMoreComments: Bool = true

    @Published private(set) var comments: [Comment] = []
    private var commentsFetchTask: Task<Void, Never>?

    @Published var showCommentsSheet: Bool = false
    @Published var commentText = ""

    // MARK: Interactions sheet properties
    @frozen
    public enum InteractionsState {
        case loading
        case display
        case error(Error)
    }

    @Published private(set) var interactionsState = InteractionsState.loading
    private var currentInteractionsOffset: Int = 0
    private(set) var hasMoreInteractions: Bool = true

    @Published private(set) var interactions: [RowUser] = []
    private var interactionsFetchTask: Task<Void, Never>?

    @Published public var showInteractionsSheet: Bool = false
    @Published var interactionsTypeForSheet: PostInteraction = .likes

    init(post: Post) {
        self.post = post

        isLiked = post.isLiked
        isViewed = post.isViewed
        isReported = post.isReported
        isDisliked = post.isDisliked

        amountLikes = post.amountLikes
        amountDislikes = post.amountDislikes
        amountViews = post.amountViews
        amountComments = post.amountComments

        showIllegalBlur = post.visibilityStatus == .illegal

        if AccountManager.shared.isCurrentUser(id: post.owner.id) {
            showSensitiveContentWarning = false
            showHeaderSensitiveWarning = false
        } else {
            if post.visibilityStatus == .hidden {
                showSensitiveContentWarning = true
            } else {
                showSensitiveContentWarning = false
            }

            if post.owner.visibilityStatus == .hidden {
                showHeaderSensitiveWarning = true
            } else {
                showHeaderSensitiveWarning = false
            }
        }
    }
}

//// MARK: - Comments
//
//extension PostViewModel2 {
//    func showComments() {
//        showCommentsSheet = true
//    }
//
//    func fetchComments(reset: Bool) {
//        if let existingTask = commentsFetchTask, !existingTask.isCancelled {
//            return
//        }
//
//        if reset {
//            comments.removeAll()
//            currentCommentsOffset = 0
//            hasMoreComments = true
//        }
//
//        if comments.isEmpty {
//            state = .loading
//        }
//
//        commentsFetchTask = Task {
//            do {
//                let result = await apiService.fetchComments(for: post.id, after: currentCommentsOffset)
//
//                try Task.checkCancellation()
//
//                switch result {
//                    case .success(let fetchedComments):
//                        await MainActor.run {
//                            comments.append(contentsOf: fetchedComments)
//
//                            if fetchedComments.count != 20 {
//                                hasMoreComments = false
//                            } else {
//                                currentCommentsOffset += 20
//                            }
//                            state = .display
//                        }
//                    case .failure(let apiError):
//                        throw apiError
//                }
//            } catch is CancellationError {
//                //
//            } catch {
//                await MainActor.run {
//                    state = .error(error)
//                }
//            }
//
//            commentsFetchTask = nil
//        }
//    }
//
//    func checkCommentRequirements() async throws {
//        if enablePostActionsConfirmation {
//            let fixedText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
//
//            if fixedText.isEmpty {
//                return
//            }
//
//            if AccountManager.shared.dailyFreeComments > 0 {
//                showCommentsSheet = false
//                PopupManager.shared.showActionFeedback(type: .freeCommentConfirmaion) { [weak self] in
//                    try await self?.sendComment()
//                } cancel: {
//                    PopupManager.shared.hideActionFeedbackPopup()
//                }
//                return
//            }
//
//            let balance = try await fetchBalance()
//
//            // Check if user has enough tokens for paid comment
//            guard balance >= Decimal(ActionFeedbackType.noFreeComments.priceInTokens) else {
//                showCommentsSheet = false
//                PopupManager.shared.showActionFeedback(type: .noTokensForComment(balance)) {
//                    PopupManager.shared.hideActionFeedbackPopup()
//                } cancel: {
//                    PopupManager.shared.hideActionFeedbackPopup()
//                }
//                return
//            }
//
//            showCommentsSheet = false
//            PopupManager.shared.showActionFeedback(type: .noFreeComments) { [weak self] in
//                try await self?.sendComment()
//            } cancel: {
//                PopupManager.shared.hideActionFeedbackPopup()
//            }
//        } else {
//            try await sendComment()
//        }
//    }
//
//    func sendComment() async throws {
//        let fixedText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if fixedText.isEmpty {
//            return
//        }
//
//        var isFreeComment = false
//
//        if AccountManager.shared.dailyFreeComments > 0 {
//            AccountManager.shared.freeCommentUsed()
//            isFreeComment = true
//        }
//
//        await MainActor.run {
//            withAnimation {
//                amountComments += 1
//            }
//        }
//
//        let result = await apiService.sendComment(for: post.id, with: fixedText)
//
//        switch result {
//            case .success(let createdComment):
//                await MainActor.run {
//                    comments.append(createdComment)
//                    commentText = ""
//                }
//            case .failure(let apiError):
//                await MainActor.run {
//                    amountComments -= 1
//                }
//                if isFreeComment {
//                    AccountManager.shared.increaseFreeComments()
//                }
//                throw apiError
//        }
//    }
//}
//
//// MARK: - Interactions
//
//extension PostViewModel2 {
//    func showInteractions(_ type: PostInteraction) {
//        interactionsTypeForSheet = type
//        showInteractionsSheet = true
//    }
//
//    public func fetchInteractions(reset: Bool) {
//        if let existingTask = interactionsFetchTask, !existingTask.isCancelled {
//            existingTask.cancel()
//        }
//
//        if reset {
//            interactions.removeAll()
//            currentInteractionsOffset = 0
//            hasMoreInteractions = true
//        }
//
//        if interactions.isEmpty {
//            interactionsState = .loading
//        }
//
//        interactionsFetchTask = Task {
//            do {
//                let apiInteractions: PostInteraction = {
//                    switch interactionsTypeForSheet {
//                        case .likes: return .likes
//                        case .dislikes: return .dislikes
//                        case .views: return .views
//                    }
//                }()
//
//                let result = await apiService.getPostInteractions(with: post.id, type: apiInteractions, after: currentInteractionsOffset)
//
//                try Task.checkCancellation()
//
//                switch result {
//                    case .success(let fetchedUsers):
//                        await MainActor.run {
//                            interactions.append(contentsOf: fetchedUsers)
//
//                            if fetchedUsers.count != 20 {
//                                hasMoreInteractions = false
//                            } else {
//                                currentInteractionsOffset += 20
//                            }
//                            interactionsState = .display
//                        }
//                    case .failure(let apiError):
//                        throw apiError
//                }
//            } catch is CancellationError {
//                //
//            } catch {
//                await MainActor.run {
//                    interactionsState = .error(error)
//                }
//            }
//
//            interactionsFetchTask = nil
//        }
//    }
//}
