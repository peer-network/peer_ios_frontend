//
//  PostDescriptionComment.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI
import Models
import DesignSystem
import Environment

struct PostDescriptionComment: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router

    @ObservedObject var postVM: PostViewModel
    let isInFeed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button {
                if !isInFeed {
                    dismiss()
                }
                router.navigate(to: .accountDetail(id: postVM.post.owner.id))
            } label: {
                Text(postVM.showHeaderSensitiveWarning ? "hidden_account" : postVM.post.owner.username)
                    .font(.custom(.bodyBoldItalic))
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    titleTextView
                        .font(.custom(.bodyBold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(-1)
                        .ifCondition(postVM.showSensitiveContentWarning || postVM.showIllegalBlur) {
                            $0
                                .allowsHitTesting(false)
                                .redacted(reason: .placeholder)
                        }

                    Text(postVM.post.formattedCreatedAtShort)
                        .font(.custom(.smallLabelRegular))
                        .foregroundStyle(Colors.whiteSecondary)
                }

                if !postVM.post.media.isEmpty, let text = postVM.attributedDescription {
                    CollapsibleText(text, lineLimit: 3)
                        .ifCondition(postVM.showSensitiveContentWarning || postVM.showIllegalBlur) {
                            $0
                                .allowsHitTesting(false)
                                .redacted(reason: .placeholder)
                        }
                }

                if isInFeed, postVM.amountComments > 0 {
                    Button {
                        postVM.showComments()
                    } label: {
                        Text("^[\(postVM.amountComments) comment](inflect: true)...")
                            .foregroundStyle(Colors.whiteSecondary)
                            .contentShape(.rect)
                    }
                }
            }
        }
        .font(.custom(.bodyRegular))
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.whitePrimary)
        .geometryGroup()
    }

    private var titleTextView: Text {
        if let attributedTitle = postVM.attributedTitle {
            return Text(attributedTitle)
        } else {
            return Text(postVM.post.title)
        }
    }
}

struct CollapsibleTextView: View {
    let attributedText: AttributedString
    let lineLimit: Int

    @State private var isExpanded: Bool = false
    @State private var needsTruncation: Bool = false
    @State private var fullTextHeight: CGFloat = 0
    @State private var truncatedTextHeight: CGFloat = 0

    init(_ text: AttributedString, lineLimit: Int = 3) {
        self.attributedText = text
        self.lineLimit = lineLimit
    }

    private var displayText: AttributedString {
        if isExpanded || !needsTruncation {
            return attributedText
        } else {
            var truncated = attributedText
            var moreText = AttributedString("... more")
            moreText.foregroundColor = .gray
            truncated.append(moreText)
            return truncated
        }
    }

    var body: some View {
        Text(displayText)
            .lineLimit(isExpanded ? nil : lineLimit)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: TruncatedHeightKey.self,
                            value: proxy.size.height
                        )
                }
            )
            .background(
                Text(attributedText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: FullHeightKey.self,
                                    value: proxy.size.height
                                )
                        }
                    )
            )
            .onPreferenceChange(FullHeightKey.self) { height in
                needsTruncation = height > truncatedTextHeight
            }
            .onPreferenceChange(TruncatedHeightKey.self) { height in
                truncatedTextHeight = height
            }
            .onTapGesture {
                if needsTruncation {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
    }
}

private struct FullHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct TruncatedHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}





//import SwiftUI
//import UIKit   // for NSTextStorage, NSLayoutManager, NSTextContainer
//
///// A SwiftUI View that collapses an AttributedString to `lineLimit` lines,
///// appending a custom “moreText” token if it overflows. Tap to expand/collapse.
//struct CollapsibleText: View {
//    let fullText: AttributedString
//    let lineLimit: Int
//    let moreText: AttributedString   // e.g. AttributedString("…\u{00A0}more")
//
//    @State private var truncatedText: AttributedString?
//    @State private var expanded = false
//
//    init(fullText: AttributedString,
//         lineLimit: Int,
//         moreText: AttributedString = AttributedString("…\u{00A0}more"))
//    {
//        self.fullText = fullText
//        self.lineLimit = lineLimit
//        self.moreText = moreText
//    }
//
//    var body: some View {
//        GeometryReader { geo in
//            Text(displayedText)
//                .fixedSize(horizontal: false, vertical: true)
//                .frame(width: geo.size.width, alignment: .leading)
//                .onTapGesture { if needsTruncation { expanded.toggle() } }
//                .onAppear { computeTruncation(for: geo.size.width) }
//                .onChange(of: geo.size.width) { computeTruncation(for: $0) }
//        }
//        // prevents the GeometryReader from occupying the entire parent
//        .frame(minHeight: 0)
//    }
//
//    private var needsTruncation: Bool {
//        guard let t = truncatedText else { return false }
//        return t != fullText
//    }
//
//    private var displayedText: AttributedString {
//        // show fullText if expanded or if nothing to truncate
//        if expanded || !needsTruncation { return fullText }
//        // otherwise show the precomputed truncated
//        return truncatedText!
//    }
//
//    private func computeTruncation(for width: CGFloat) {
//        guard width > 0 else { return }  // wait until we actually know the width
//
//        // bridge to NSAttributedString
//        let nsFull  = NSAttributedString(fullText)
//        let nsToken = NSAttributedString(moreText)
//
//        // helper: build a TextKit stack for a given NSAttributedString
//        func makeLayoutManager(for text: NSAttributedString) -> NSLayoutManager {
//            let storage = NSTextStorage(attributedString: text)
//            let manager = NSLayoutManager()
//            let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
//            container.lineBreakMode = .byWordWrapping
//            container.maximumNumberOfLines = lineLimit
//            container.lineFragmentPadding = 0
//            manager.addTextContainer(container)
//            storage.addLayoutManager(manager)
//            manager.ensureLayout(for: container)
//            return manager
//        }
//
//        // 1) measure how many characters of `nsFull` fit in `lineLimit` lines
//        let fullMgr = makeLayoutManager(for: nsFull)
//        let fullGlyphRange = fullMgr.glyphRange(for: fullMgr.textContainers.first!)
//        let fullCharRange  = fullMgr.characterRange(
//            forGlyphRange: fullGlyphRange,
//            actualGlyphRange: nil
//        )
//        let fitLen = fullCharRange.length
//
//        // 2) if everything fits, no truncation needed
//        if fitLen >= nsFull.length {
//            truncatedText = fullText
//            return
//        }
//
//        // 3) binary‑search the maximum prefix so that prefix+token still fits
//        var low = 0, high = fitLen
//        let tokenLen = nsToken.length
//
//        while low < high {
//            let mid = (low + high + 1) / 2
//            // take prefix [0..<mid]
//            let prefix = NSMutableAttributedString(
//                attributedString: nsFull.attributedSubstring(
//                    from: NSRange(location: 0, length: mid)
//                )
//            )
//            // trim any trailing commas/spaces so you don’t get “foo, … more”
//            let trimmed = prefix.string
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//                .trimmingCharacters(in: CharacterSet(charactersIn: ",;:"))
//            prefix.replaceCharacters(
//                in: NSRange(location: 0, length: prefix.length),
//                with: trimmed
//            )
//            // append “… more”
//            prefix.append(nsToken)
//
//            let mgr = makeLayoutManager(for: prefix)
//            let glyphRange = mgr.glyphRange(for: mgr.textContainers.first!)
//            let charRange  = mgr.characterRange(
//                forGlyphRange: glyphRange,
//                actualGlyphRange: nil
//            )
//
//            // if the candidate (prefix+token) fully fits, try longer; else shorter
//            if charRange.length == mid + tokenLen {
//                low = mid
//            } else {
//                high = mid - 1
//            }
//        }
//
//        // 4) build your final truncated string
//        let bestPrefix = nsFull.attributedSubstring(
//            from: NSRange(location: 0, length: low)
//        )
//        let out = NSMutableAttributedString(attributedString: bestPrefix)
//        // final trim
//        let finalTrim = out.string
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//            .trimmingCharacters(in: CharacterSet(charactersIn: ",;:"))
//        out.mutableString.setString(finalTrim)
//        out.append(nsToken)
//
//        // go back to SwiftUI AttributedString
//        if let result = try? AttributedString(out) {
//            truncatedText = result
//        } else {
//            truncatedText = AttributedString(out.string)
//        }
//    }
//}
