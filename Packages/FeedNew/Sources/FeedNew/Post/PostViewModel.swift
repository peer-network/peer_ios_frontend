//
//  PostViewModel.swift
//  FeedNew
//
//  Created by Артем Васин on 31.01.25.
//

import SwiftUI
import Models
import Environment

@MainActor
public final class PostViewModel: ObservableObject {
    let post: Post
    public unowned var apiService: APIService!

    @Published public var lineLimit: Int?
    public var isCollapsed: Bool = true {
        didSet {
            recalcCollapse()
        }
    }

    @Published public private(set) var isLiked: Bool
    @Published public private(set) var isViewed: Bool
    @Published public private(set) var isReported: Bool
    @Published public private(set) var isDisliked: Bool
    @Published public private(set) var isSaved: Bool

    @Published public private(set) var amountLikes: Int
    @Published public private(set) var amountDislikes: Int
    @Published public private(set) var amountViews: Int
    @Published public private(set) var amountComments: Int

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

        recalcCollapse()
    }

    public var attributedString: AttributedString {
        let hashtagPattern = "#[\\w_]{3,50}"

        let inputText = post.mediaDescription

        var attributedString = AttributedString(inputText)
        let regex = try? NSRegularExpression(pattern: hashtagPattern)
        let nsRange = NSRange(inputText.startIndex..<inputText.endIndex, in: inputText)

        if let matches = regex?.matches(in: inputText, range: nsRange) {
            for match in matches {
                if let range = Range(match.range, in: inputText) {
                    let attributedRange = attributedString.range(of: String(inputText[range]))
                    if let attributedRange = attributedRange {
                        attributedString[attributedRange].foregroundColor = .blue
                    }
                }
            }
        }
        return attributedString
    }

    public func toggleLike() async throws {
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

        withAnimation {
            isLiked = true
            amountLikes += 1
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
            isLiked = false
            amountLikes -= 1
            if isFreeLike {
                AccountManager.shared.increaseFreeLikes()
            }
            throw PostActionError.serverError
        }
    }

    public func toggleDislike() async throws {
        guard !isDisliked else {
            throw PostActionError.alreadyDisliked
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostDislike
        }

        withAnimation {
            isDisliked = true
            amountDislikes += 1
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
            isDisliked = false
            amountDislikes -= 1
            throw PostActionError.serverError
        }
    }

    public func toggleView() async throws {
        guard !isViewed else {
            throw PostActionError.alreadyViewed
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostView
        }

        withAnimation {
            isViewed = true
            amountViews += 1
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
            isViewed = false
            amountViews -= 1
            throw PostActionError.serverError
        }
    }

    public func toggleReport() async throws {
        guard !isReported else {
            throw PostActionError.alreadyReported
        }

        guard !AccountManager.shared.isCurrentUser(id: post.owner.id) else {
            throw PostActionError.ownPostReport
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
            throw PostActionError.serverError
        }

        isReported = true
    }

    private func recalcCollapse() {
        let showCollapseButton = isCollapsed && post.mediaDescription.unicodeScalars.count > Constants.collapseThresholdLength
        let newlineLimit = showCollapseButton && isCollapsed ? Constants.collapsedLines : nil
        if newlineLimit != lineLimit {
            lineLimit = newlineLimit
        }
    }
}
