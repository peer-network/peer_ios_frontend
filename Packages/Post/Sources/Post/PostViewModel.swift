//
//  PostViewModel.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import Models
import Foundation
import Environment
import DesignSystem

@MainActor
public final class PostViewModel: ObservableObject {
    public unowned var apiService: APIService!

    @AppStorage("enablePostActionsConfirmation", store: UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")) private var enablePostActionsConfirmation = true

    // MARK: Post properties
    public var post: Post

    @Published public private(set) var isLiked: Bool
    @Published public private(set) var isViewed: Bool
    @Published public private(set) var isReported: Bool
    @Published public private(set) var isDisliked: Bool
    @Published public private(set) var isSaved: Bool

    @Published public private(set) var amountLikes: Int
    @Published public private(set) var amountDislikes: Int
    @Published public private(set) var amountViews: Int
    @Published public private(set) var amountComments: Int

    @Published public private(set) var description: String?
    @Published public private(set) var attributedDescription: AttributedString?
    @Published public private(set) var attributedTitle: AttributedString?

    @Published public private(set) var lineLimit: Int?
    @Published public private(set) var shouldShowCollapseButton: Bool = false
    public var isCollapsed: Bool = true {
        didSet {
            recalcCollapse()
        }
    }

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

    @Published var showInteractionsSheet: Bool = false
    @Published var interactionsTypeForSheet: InteractionType = .likes

    @Published var showShareSheet = false

    @Published var showSensitiveContentWarning: Bool
    public let showIllegalBlur: Bool

    @Published var showHeaderSensitiveWarning: Bool

    public init(post: Post) {
        self.post = post

        isLiked = post.isLiked
        isViewed = post.isViewed
        isReported = post.isReported
        isDisliked = post.isDisliked
        isSaved = post.isSaved

        amountLikes = post.amountLikes
        amountDislikes = post.amountDislikes
        amountViews = post.amountViews
        amountComments = post.amountComments

        attributedTitle = post.title.createAttributedString()

//        // TODO: REMOVE THIS TESTING SETTERS
//        showSensitiveContentWarning = false
//        showHeaderSensitiveWarning = true
//        showIllegalBlur = false
//        self.post.owner.username = "hidden_account"
//        self.post.owner.image = "hidden_account"




        showIllegalBlur = post.visibilityStatus == .illegal
        if !AccountManager.shared.isCurrentUser(id: post.owner.id) {
            if post.visibilityStatus == .hidden {
                showSensitiveContentWarning = true
            } else {
                showSensitiveContentWarning = false
            }

            if post.owner.visibilityStatus == .hidden {
                showHeaderSensitiveWarning = true
            } else {
                showHeaderSensitiveWarning = false
                if post.owner.visibilityStatus == .illegal {
                    self.post.owner.username = "hidden_account"
                    self.post.owner.image = "hidden_account"
                }
            }
        } else {
            showSensitiveContentWarning = false
            showHeaderSensitiveWarning = false
        }

        if post.contentType == .text {
            fetchTextPostBody()
        } else {
            if !post.mediaDescription.isEmpty {
                description = post.mediaDescription
                attributedDescription = post.mediaDescription.createAttributedString()
                recalcCollapse()
            }
        }
    }

    private func fetchTextPostBody() {
        Task { [weak self] in
            guard let self else { return }
            guard let url = post.mediaURLs.first else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else { return }
            await MainActor.run {
                self.description = text
                self.attributedDescription = text.createAttributedString()
            }
            recalcCollapse()
        }
    }
}

// MARK: - Post Actions

extension PostViewModel {
    private func fetchBalance() async throws(APIError) -> Double {
        let result = await apiService.fetchLiquidityState()

        switch result {
            case .success(let amount):
                return amount
            case .failure(let apiError):
                throw apiError
        }
    }

    public func like() async throws {
        guard !isLiked else {
            throw PostActionError.alreadyLiked
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostLike
        }

        if enablePostActionsConfirmation {
            // Check if we need to show confirmation
            if AccountManager.shared.dailyFreeLikes > 0 {
                // Show free like confirmation
                PopupManager.shared.showActionFeedback(type: .freeLikeConfirmaion) { [weak self] in
                    try await self?.confirmLike()
                } cancel: {
                    PopupManager.shared.hideActionFeedbackPopup()
                }
                return
            }

            let balance = try await fetchBalance()

            // Check if user has enough tokens for paid like
            guard balance >= ActionFeedbackType.noFreeLikes.priceInTokens else {
                PopupManager.shared.showActionFeedback(type: .noTokensForLike(balance)) {
                    PopupManager.shared.hideActionFeedbackPopup()
                } cancel: {
                    PopupManager.shared.hideActionFeedbackPopup()
                }
                return
            }

            // Show confirmation for paid like if no free likes left
            PopupManager.shared.showActionFeedback(type: .noFreeLikes) { [weak self] in
                try await self?.confirmLike()
            } cancel: {
                PopupManager.shared.hideActionFeedbackPopup()
            }
        } else {
            try await confirmLike()
        }
    }

    public func confirmLike() async throws {
        var isFreeLike = false

        if AccountManager.shared.dailyFreeLikes > 0 {
            AccountManager.shared.freeLikeUsed()
            isFreeLike = true
        }

        await MainActor.run {
            withAnimation {
                isLiked = true
                amountLikes += 1
            }
        }

        do {
            let result = await apiService.likePost(with: post.id)

            switch result {
                case .success:
                    if let username = AccountManager.shared.user?.username {
                        let postTitle = post.title
                        let targetUid = post.owner.id

                        NotificationService.sendLikeNotification(
                            username:  username,
                            postTitle: postTitle,
                            targetUid: targetUid
                        ) { result in
                            switch result {
                                case .success():
                                    print("✅ Like notification requested")
                                case .failure(let error):
                                    print("❌ Error sending notification:", error)
                                    dump(error)
                            }
                        }
                    }
                    break
                case .failure(let apiError):
                    throw apiError
            }
        } catch {
            await MainActor.run {
                isLiked = false
                amountLikes -= 1
            }
            if isFreeLike {
                AccountManager.shared.increaseFreeLikes()
            }
            throw error
        }
    }

    public func dislike() async throws {
        guard !isDisliked else {
            throw PostActionError.alreadyDisliked
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostDislike
        }

        if enablePostActionsConfirmation {
            let balance = try await fetchBalance()

            guard balance >= ActionFeedbackType.dislikeConfirmaion.priceInTokens else {
                PopupManager.shared.showActionFeedback(type: .noTokensForDislike(balance)) {
                    PopupManager.shared.hideActionFeedbackPopup()
                } cancel: {
                    PopupManager.shared.hideActionFeedbackPopup()
                }
                return
            }

            // Always show confirmation for dislikes since they always cost
            PopupManager.shared.showActionFeedback(type: .dislikeConfirmaion) { [weak self] in
                try await self?.confirmDislike()
            } cancel: {
                PopupManager.shared.hideActionFeedbackPopup()
            }
        } else {
            try await confirmDislike()
        }
    }

    public func confirmDislike() async throws {
        await MainActor.run {
            withAnimation {
                isDisliked = true
                amountDislikes += 1
            }
        }

        do {
            let result = await apiService.dislikePost(with: post.id)

            switch result {
            case .success:
                break
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            await MainActor.run {
                isDisliked = false
                amountDislikes -= 1
            }
            throw error
        }
    }

    public func view() async throws {
        guard !isViewed else {
            throw PostActionError.alreadyViewed
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostView
        }

        await MainActor.run {
            withAnimation {
                isViewed = true
                amountViews += 1
            }
        }

        do {
            let result = await apiService.markPostViewed(with: post.id)

            switch result {
            case .success:
                break
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            await MainActor.run {
                isViewed = false
                amountViews -= 1
            }
            throw error
        }
    }

    public func report() async throws {
        guard !isReported else {
            throw PostActionError.alreadyReported
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostReport
        }

        await MainActor.run {
            isReported = true
        }
        do {
            let result = await apiService.reportPost(with: post.id)

            switch result {
            case .success:
                break
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            await MainActor.run {
                isReported = false
            }
            throw error
        }
    }

    public func blockContent() async throws -> Bool {
        do {
            let result = await apiService.toggleHideUserContent(with: post.owner.id)

            switch result {
            case .success(let isBlocked):
                return isBlocked
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            throw error
        }
    }
}

// MARK: - Comments

extension PostViewModel {
    public func showComments() {
        showCommentsSheet = true
    }

    public func fetchComments(reset: Bool) {
        if let existingTask = commentsFetchTask, !existingTask.isCancelled {
            return
        }
        
        if reset {
            comments.removeAll()
            currentCommentsOffset = 0
            hasMoreComments = true
        }

        if comments.isEmpty {
            state = .loading
        }

        commentsFetchTask = Task {
            do {
                let result = await apiService.fetchComments(for: post.id, after: currentCommentsOffset)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedComments):
                        await MainActor.run {
                            comments.append(contentsOf: fetchedComments)

                            if fetchedComments.count != Constants.postCommentsLimit {
                                hasMoreComments = false
                            } else {
                                currentCommentsOffset += Constants.postCommentsLimit
                            }
                            state = .display
                        }
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                await MainActor.run {
                    state = .error(error)
                }
            }

            commentsFetchTask = nil
        }
    }

    public func checkCommentRequirements() async throws {
        if enablePostActionsConfirmation {
            let fixedText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)

            if fixedText.isEmpty {
                return
            }

            if AccountManager.shared.dailyFreeComments > 0 {
                showCommentsSheet = false
                PopupManager.shared.showActionFeedback(type: .freeCommentConfirmaion) { [weak self] in
                    try await self?.sendComment()
                } cancel: {
                    PopupManager.shared.hideActionFeedbackPopup()
                }
                return
            }

            let balance = try await fetchBalance()

            // Check if user has enough tokens for paid comment
            guard balance >= ActionFeedbackType.noFreeComments.priceInTokens else {
                showCommentsSheet = false
                PopupManager.shared.showActionFeedback(type: .noTokensForComment(balance)) {
                    PopupManager.shared.hideActionFeedbackPopup()
                } cancel: {
                    PopupManager.shared.hideActionFeedbackPopup()
                }
                return
            }

            showCommentsSheet = false
            PopupManager.shared.showActionFeedback(type: .noFreeComments) { [weak self] in
                try await self?.sendComment()
            } cancel: {
                PopupManager.shared.hideActionFeedbackPopup()
            }
        } else {
            try await sendComment()
        }
    }

    public func sendComment() async throws {
        let fixedText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)

        if fixedText.isEmpty {
            return
        }

        var isFreeComment = false

        if AccountManager.shared.dailyFreeComments > 0 {
            AccountManager.shared.freeCommentUsed()
            isFreeComment = true
        }

        await MainActor.run {
            withAnimation {
                amountComments += 1
            }
        }

        let result = await apiService.sendComment(for: post.id, with: fixedText)

        switch result {
            case .success(let createdComment):
                await MainActor.run {
                    comments.append(createdComment)
                    commentText = ""
                }
            case .failure(let apiError):
                await MainActor.run {
                    amountComments -= 1
                }
                if isFreeComment {
                    AccountManager.shared.increaseFreeComments()
                }
                throw apiError
        }
    }
}

// MARK: - Interactions

extension PostViewModel {
    func showInteractions(_ type: InteractionType) {
        interactionsTypeForSheet = type
        showInteractionsSheet = true
    }

    public func fetchInteractions(reset: Bool) {
        if let existingTask = interactionsFetchTask, !existingTask.isCancelled {
            existingTask.cancel()
        }

        if reset {
            interactions.removeAll()
            currentInteractionsOffset = 0
            hasMoreInteractions = true
        }

        if interactions.isEmpty {
            interactionsState = .loading
        }

        interactionsFetchTask = Task {
            do {
                let apiInteractions: PostInteraction = {
                    switch interactionsTypeForSheet {
                        case .likes: return .likes
                        case .dislikes: return .dislikes
                        case .views: return .views
                    }
                }()
                
                let result = await apiService.getPostInteractions(with: post.id, type: apiInteractions, after: currentInteractionsOffset)

                try Task.checkCancellation()

                switch result {
                    case .success(let fetchedUsers):
                        await MainActor.run {
                            interactions.append(contentsOf: fetchedUsers)

                            if fetchedUsers.count != Constants.postInteractionsLimit {
                                hasMoreInteractions = false
                            } else {
                                currentInteractionsOffset += Constants.postInteractionsLimit
                            }
                            interactionsState = .display
                        }
                    case .failure(let apiError):
                        throw apiError
                }
            } catch is CancellationError {
                //                state = .display(posts: posts, hasMore: .hasMore)
            } catch {
                await MainActor.run {
                    interactionsState = .error(error)
                }
            }

            interactionsFetchTask = nil
        }
    }
}

// MARK: - Helper methods

extension PostViewModel {
    private func recalcCollapse() {
        guard let description else { return }
        guard description.count > Constants.collapseThresholdLength else { return }

        shouldShowCollapseButton = true

        let newLineLimit = isCollapsed ? Constants.collapsedLines : nil

        if newLineLimit != lineLimit {
            lineLimit = newLineLimit
        }
    }
}

extension PostViewModel {
    public convenience init?(id: String, apiService: APIService) async {
        do {
            let post = try await PostViewModel.fetchPost(id: id, service: apiService)

            self.init(post: post)
        } catch {
            return nil
        }
    }

    private static func fetchPost(id: String, service: APIService) async throws -> Post {
        let result = await service.fetchPostById(id)

        try Task.checkCancellation()

        switch result {
            case .success(let fetchedPost):
                return fetchedPost
            case .failure(let apiError):
                throw apiError
        }
    }
}
