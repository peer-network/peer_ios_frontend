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

@MainActor
public final class PostViewModel: ObservableObject {
    public unowned var apiService: APIService!

    // MARK: Post properties
    public let post: Post

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
    public func like() async throws {
        guard !isLiked else {
            throw PostActionError.alreadyLiked
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostLike
        }

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
            let result = await apiService.likePost(with: post.id) // TODO: CRASHES THE APP NOW. FeedNew/PostViewModel.swift:96: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value

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
            if isFreeLike {
                AccountManager.shared.increaseFreeLikes()
            }
            throw APIError.unknownError(error: error)
        }
    }

    public func dislike() async throws {
        guard !isDisliked else {
            throw PostActionError.alreadyDisliked
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostDislike
        }

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
            throw APIError.unknownError(error: error)
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
            throw APIError.unknownError(error: error)
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
            throw APIError.unknownError(error: error)
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

    public func sendComment(_ text: String) async throws {
        let fixedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

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
