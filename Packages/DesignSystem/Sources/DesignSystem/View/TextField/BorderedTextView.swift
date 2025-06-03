//
//  BorderedTextView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 27.05.25.
//

import SwiftUI

public struct BorderedTextView<Value: Hashable>: UIViewRepresentable {
    @Binding var text: String
    @Binding var hashtags: [String]
    @Binding var dynamicHeight: CGFloat

    let placeholder: String
    let maxLength: Int
    let minHeight: CGFloat
    let allowNewLines: Bool

    @FocusState.Binding var focusState: Value?
    let focusEquals: Value?

    public init(
        text: Binding<String>,
        hashtags: Binding<[String]>,
        height: Binding<CGFloat>,
        minHeight: CGFloat,
        placeholder: String,
        maxLength: Int,
        allowNewLines: Bool,
        focusState: FocusState<Value?>.Binding,
        focusEquals: Value?
    ) {
        self._text = text
        self._hashtags = hashtags
        self._dynamicHeight = height
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.minHeight = minHeight
        self.allowNewLines = allowNewLines
        self._focusState = focusState
        self.focusEquals = focusEquals
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.customFont(weight: .regular, style: .footnote)
        textView.backgroundColor = .clear
        textView.textColor = Colors.whitePrimary.uiColor
        textView.tintColor = Colors.whitePrimary.uiColor
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.maximumNumberOfLines = 0

        // Set initial text
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = Colors.whiteSecondary.uiColor
        } else {
            textView.text = text
            context.coordinator.formatText(in: textView)
        }

        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if !allowNewLines {
            textView.returnKeyType = .done
        }

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self

        // Only handle focus changes when not actively editing
        if !context.coordinator.isEditing {
            if focusState == focusEquals && !uiView.isFirstResponder {
                DispatchQueue.main.async {
                    uiView.becomeFirstResponder()
                }
            } else if focusState != focusEquals && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }

        // Enforce max length if text exceeds the new limit
        if text.count > maxLength {
            let truncatedText = String(text.prefix(maxLength))
            self.text = truncatedText
            uiView.text = truncatedText
            context.coordinator.formatText(in: uiView)
        }

        // Update text only when it comes from external source (not user input)
        if !context.coordinator.isEditing && uiView.text != text {
            if text.isEmpty {
                uiView.text = placeholder
                uiView.textColor = Colors.whiteSecondary.uiColor
            } else {
                uiView.text = text
                context.coordinator.formatText(in: uiView)
            }
            context.coordinator.updateHeight(for: uiView)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: BorderedTextView
        var isEditing = false
        private var lastText: String = ""
        private var lastHeight: CGFloat = 0

        init(_ parent: BorderedTextView) {
            self.parent = parent
            self.lastText = parent.text
        }

        // MARK: - UITextViewDelegate Methods

        public func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            if textView.textColor == Colors.whiteSecondary.uiColor {
                textView.text = ""
                textView.textColor = Colors.whitePrimary.uiColor
            }
        }

        public func textViewDidChange(_ textView: UITextView) {
            guard textView.markedTextRange == nil else { return }

            isEditing = true

            // Enforce max length
            if textView.text.count > parent.maxLength {
                textView.text = String(textView.text.prefix(parent.maxLength))
            }

            // Only update if text actually changed
            if textView.text != lastText {
                lastText = textView.text
                parent.text = textView.text

                // Only format if the change might affect hashtags/URLs
//                let needsFormatting = textView.text.contains("#") || textView.text.contains("http")
//                if needsFormatting {
                    formatText(in: textView)
//                }
            }

            updateHeight(for: textView)
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = Colors.whiteSecondary.uiColor
                parent.text = ""
            }
            isEditing = false
        }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }

            // Prevent new lines if not allowed
            if !parent.allowNewLines && text == "\n" {
                textView.resignFirstResponder()  // Dismiss keyboard on return press
                return false
            }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= parent.maxLength
        }

        // MARK: - Helper Methods

        func formatText(in textView: UITextView) {
            guard !textView.text.isEmpty, textView.text != parent.placeholder else {
                textView.textColor = Colors.whiteSecondary.uiColor
                parent.hashtags.removeAll()
                return
            }

            let currentText = textView.text ?? ""
            let selectedRange = textView.selectedRange

            let attributedString = NSMutableAttributedString(string: currentText)
            let wholeRange = NSRange(location: 0, length: attributedString.length)

            // Set default attributes
            attributedString.addAttributes([
                .font: UIFont.customFont(weight: .regular, style: .footnote),
                .foregroundColor: Colors.whitePrimary.uiColor
            ], range: wholeRange)

            // Clear previous hashtags
            parent.hashtags.removeAll()

            // Find and format hashtags
            let hashtagPattern = "#[\\p{L}\\p{N}_]{3,50}"
            if let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern) {
                let hashtagMatches = hashtagRegex.matches(in: currentText, range: wholeRange)

                for match in hashtagMatches {
                    let hashtagWithSymbol = attributedString.attributedSubstring(from: match.range).string
                    let hashtag = String(hashtagWithSymbol.dropFirst())
                    parent.hashtags.append(hashtag)

                    attributedString.addAttributes([
                        .foregroundColor: Colors.hashtag.uiColor
                    ], range: match.range)
                }
            }

            // Find and format URLs
            if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
                let urlMatches = detector.matches(in: currentText, range: wholeRange)

                for match in urlMatches {
                    attributedString.addAttributes([
                        .foregroundColor: Colors.hashtag.uiColor,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .underlineColor: Colors.hashtag.uiColor
                    ], range: match.range)
                }
            }

            // Apply to text view while preserving cursor position
            textView.attributedText = attributedString
            textView.selectedRange = selectedRange
        }

        func updateHeight(for textView: UITextView) {
            let fixedWidth = textView.frame.width
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newHeight = max(newSize.height, parent.minHeight)

            if abs(newHeight - lastHeight) > 1 {
                lastHeight = newHeight
                DispatchQueue.main.async { [weak self] in
                    self?.parent.dynamicHeight = newHeight
                }
            }
        }
    }
}
