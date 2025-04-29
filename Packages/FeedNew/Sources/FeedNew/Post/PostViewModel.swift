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

    @Published public private(set) var lineLimit: Int?
    @Published public private(set) var shouldShowCollapseButton: Bool = false
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

    @Published public private(set) var description: String?
    @Published public private(set) var attributedDescription: AttributedString?

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

        if post.contentType == .text {
            fetchTextPostBody()
        } else {
            if !post.mediaDescription.isEmpty {
                description = post.mediaDescription
                attributedDescription = makeAttributedString(from: post.mediaDescription)
                recalcCollapse()
            }
        }
    }

    private func makeAttributedString(from inputText: String) -> AttributedString {
        var attributedString = AttributedString(inputText)

        // Helper function to safely convert NSRange to Range<AttributedString.Index>
        func attributedRange(from nsRange: NSRange, in string: String) -> Range<AttributedString.Index>? {
            guard let stringRange = Range(nsRange, in: string) else { return nil }

            let startIndex = attributedString.characters.index(
                attributedString.startIndex,
                offsetBy: string.distance(from: string.startIndex, to: stringRange.lowerBound)
            )
            let endIndex = attributedString.characters.index(
                startIndex,
                offsetBy: string.distance(from: stringRange.lowerBound, to: stringRange.upperBound)
            )

            return startIndex..<endIndex
        }

        // First process URLs
        let urlPattern = #"(?i)\b((https?|ftp):\/\/)?(([\w-]+\.)+[\w-]{2,}|localhost|\d{1,3}(\.\d{1,3}){3})(:\d+)?(\/[^\s?#]*)?(\?[^\s#]*)?(#[^\s]*)?\b"#

        if let urlRegex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive) {
            let nsRange = NSRange(inputText.startIndex..<inputText.endIndex, in: inputText)

            urlRegex.enumerateMatches(in: inputText, range: nsRange) { match, _, _ in
                guard let match = match,
                      let attributedRange = attributedRange(from: match.range, in: inputText) else { return }

                let substring = String(inputText[Range(match.range, in: inputText)!])
                var urlString = substring

                if !substring.lowercased().hasPrefix("http") {
                    urlString = "https://" + substring
                }

                attributedString[attributedRange].foregroundColor = .systemBlue
                attributedString[attributedRange].underlineStyle = .single
                attributedString[attributedRange].underlineColor = .systemBlue
                if let url = URL(string: urlString) {
                    attributedString[attributedRange].link = url
                }
            }
        }

        // Then process hashtags
        let hashtagPattern = "#[\\p{L}\\p{N}_]{3,50}"
        if let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern) {
            let nsRange = NSRange(inputText.startIndex..<inputText.endIndex, in: inputText)

            hashtagRegex.enumerateMatches(in: inputText, range: nsRange) { match, _, _ in
                guard let match = match,
                      let attributedRange = attributedRange(from: match.range, in: inputText),
                      attributedString[attributedRange].link == nil else { return }

                attributedString[attributedRange].foregroundColor = .blue
            }
        }

        return attributedString
    }

    private func fetchTextPostBody() {
        Task { [weak self] in
            guard let self else { return }
            guard let url = post.mediaURLs.first else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else { return }
            description = text
            attributedDescription = makeAttributedString(from: text)
            recalcCollapse()
        }
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
        guard let description else { return }
        guard description.count > Constants.collapseThresholdLength else { return }

        shouldShowCollapseButton = true

        let newLineLimit = isCollapsed ? Constants.collapsedLines : nil

        if newLineLimit != lineLimit {
            lineLimit = newLineLimit
        }
    }
}
