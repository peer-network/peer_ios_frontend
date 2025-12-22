//
//  String+Extensions.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import Foundation

extension String {
    func createAttributedString() -> AttributedString {
        var attributedString = AttributedString(self)

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
            let nsRange = NSRange(self.startIndex..<self.endIndex, in: self)

            urlRegex.enumerateMatches(in: self, range: nsRange) { match, _, _ in
                guard let match = match,
                      let attributedRange = attributedRange(from: match.range, in: self) else { return }

                let substring = String(self[Range(match.range, in: self)!])
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
        let hashtagPattern = "#[\\p{L}\\p{N}_]{2,53}"
        if let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern) {
            let nsRange = NSRange(self.startIndex..<self.endIndex, in: self)

            hashtagRegex.enumerateMatches(in: self, range: nsRange) { match, _, _ in
                guard let match = match,
                      let attributedRange = attributedRange(from: match.range, in: self),
                      attributedString[attributedRange].link == nil else { return }

                let hashtag = String(self[Range(match.range, in: self)!])
                let tag = String(hashtag.dropFirst())

                if let url = URL(string: "peer://hashtag/\(tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tag)") {
                    attributedString[attributedRange].link = url
                    attributedString[attributedRange].foregroundColor = .blue
                }
            }
        }

        return attributedString
    }
}
