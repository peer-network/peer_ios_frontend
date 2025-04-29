//
//  SingleCommentViewModel.swift
//  FeedNew
//
//  Created by Artem Vasin on 29.04.25.
//

import Models
import SwiftUI
import Environment
import Networking

@MainActor
final class SingleCommentViewModel: ObservableObject {
    let comment: Comment
    public unowned var apiService: APIService!

    @Published public private(set) var isLiked: Bool
    @Published public private(set) var amountLikes: Int
    @Published public private(set) var attributedContent: AttributedString?

    public init(comment: Comment) {
        self.comment = comment

        isLiked = comment.isLiked
        amountLikes = comment.amountLikes

        attributedContent = makeAttributedString(from: comment.content)
    }

    func likeComment() async throws {
        guard !comment.isLiked else {
            throw CommentError.alreadyLiked
        }

        guard !AccountManager.shared.isCurrentUser(id: comment.user.id) else {
            throw CommentError.ownLike
        }

        withAnimation {
            isLiked = true
            amountLikes += 1
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
            isLiked = false
            amountLikes -= 1
            throw CommentError.serverError(.missingData)
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
        let urlPattern = #"(?i)\b((https?|ftp):\/\/)?(([\w-]+\.)+[a-z]{2,})(:\d+)?(\/[^\s?#]*)?(\?[^\s#]*)?(#[^\s]*)?\b"#

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
}
