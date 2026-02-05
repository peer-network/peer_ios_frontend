//
//  CollapsibleText.swift
//  DesignSystem
//
//  Created by Artem Vasin on 29.07.25.
//

import SwiftUI

/// A SwiftUI view that displays an AttributedString collapsed to `lineLimit` lines,
/// appending `moreText` if it doesn’t fit. Tap to expand/collapse.
public struct CollapsibleText: View {
    private let fullText: AttributedString
    private let lineLimit: Int

    private let moreAttributedString: NSAttributedString

    public init(_ fullText: AttributedString, lineLimit: Int) {
        self.fullText = fullText
        self.lineLimit = lineLimit

        let moreStringAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.whiteSecondary.uiColor
        ]
        moreAttributedString = NSAttributedString(string: "See more", attributes: moreStringAttributes)
    }

    @State private var truncatedText: AttributedString?
    @State private var expanded: Bool = false

    public var body: some View {
        Button {
            withAnimation(.snappy) {
                expanded.toggle()
            }
        } label: {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
        }
        .buttonStyle(TextTappedButtonStyle())
    }

    private var content: some View {
        Group {
            if expanded {
                // show full text when expanded
                Text(fullText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // if we’ve already computed a truncated version, show it…
                if let truncatedText = truncatedText {
                    Text(truncatedText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    // otherwise, render full text in a hidden Text to measure width,
                    // then compute truncatedText onAppear / width change
                    Text(fullText)
                        .lineLimit(lineLimit)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    self.computeTruncation(for: geo.size.width)
                                }
                                .onChange(of: geo.size.width) { newWidth in
                                    self.computeTruncation(for: newWidth)
                                }
                        })
                }
            }
        }
    }

    private func computeTruncation(for containerWidth: CGFloat) {
        let nsFull = NSAttributedString(fullText)

        // 2. Set up TextKit stack
        let textStorage = NSTextStorage(attributedString: nsFull)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))

        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = lineLimit
        textContainer.lineBreakMode = .byWordWrapping

        // Critical for custom fonts:
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // 3. Force layout
        layoutManager.ensureLayout(for: textContainer)

        // 4. Count lines properly
        var lineCount = 0
        var index = 0
        let glyphRange = layoutManager.glyphRange(for: textContainer)

        // 5. Apply truncation if needed (rest of your existing logic)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        if charRange.length < nsFull.length {
            let visiblePart = nsFull.attributedSubstring(from: NSRange(location: 0, length: charRange.length))
            let mutable = NSMutableAttributedString(attributedString: visiblePart)
            mutable.append(NSAttributedString(string: "...\u{00A0}"))
            mutable.append(moreAttributedString)
            truncatedText = AttributedString(mutable)
        } else {
            truncatedText = fullText
        }
    }
}

fileprivate struct TextTappedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                Color.black.opacity(configuration.isPressed ? 0.3 : 0)
                    .mask(configuration.label) // Mask to text shape
            )
    }
}
