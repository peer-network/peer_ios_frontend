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

    // Plain Binding (drive focus ourselves)
    @Binding var focusState: Value?
    let focusEquals: Value?

    // Toolbar
    let toolbarButtonTitle: String?
    let onToolbarButtonTap: (() -> Void)?

    // MARK: - Primary initializer (preferred)
    public init(
        text: Binding<String>,
        hashtags: Binding<[String]>,
        height: Binding<CGFloat>,
        minHeight: CGFloat,
        placeholder: String,
        maxLength: Int,
        allowNewLines: Bool,
        focusState: Binding<Value?>,
        focusEquals: Value?,
        toolbarButtonTitle: String? = nil,
        onToolbarButtonTap: (() -> Void)? = nil
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

        self.toolbarButtonTitle = toolbarButtonTitle
        self.onToolbarButtonTap = onToolbarButtonTap
    }

    // MARK: - Compatibility initializer (keeps old call sites compiling)
    public init(
        text: Binding<String>,
        hashtags: Binding<[String]>,
        height: Binding<CGFloat>,
        minHeight: CGFloat,
        placeholder: String,
        maxLength: Int,
        allowNewLines: Bool,
        focusState: FocusState<Value?>.Binding,
        focusEquals: Value?,
        toolbarButtonTitle: String? = nil,
        onToolbarButtonTap: (() -> Void)? = nil
    ) {
        self.init(
            text: text,
            hashtags: hashtags,
            height: height,
            minHeight: minHeight,
            placeholder: placeholder,
            maxLength: maxLength,
            allowNewLines: allowNewLines,
            focusState: Binding(
                get: { focusState.wrappedValue },
                set: { focusState.wrappedValue = $0 }
            ),
            focusEquals: focusEquals,
            toolbarButtonTitle: toolbarButtonTitle,
            onToolbarButtonTap: onToolbarButtonTap
        )
    }

    public func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator

        tv.font = UIFont.customFont(weight: .regular, style: .footnote)
        tv.backgroundColor = .clear
        tv.textColor = Colors.whitePrimary.uiColor
        tv.tintColor = Colors.whitePrimary.uiColor
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0

        tv.isScrollEnabled = false
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.textContainer.maximumNumberOfLines = 0

        // Return key behavior
        tv.returnKeyType = allowNewLines ? .default : .done

        // Initial text / placeholder
        if text.isEmpty {
            tv.text = placeholder
            tv.textColor = Colors.whiteSecondary.uiColor
        } else {
            tv.text = text
            context.coordinator.formatText(in: tv)
        }

        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Toolbar
        context.coordinator.applyToolbarIfNeeded(title: toolbarButtonTitle, to: tv)

        return tv
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        // keep freshest bindings/closures
        context.coordinator.parent = self

        // keep delegate connected
        if uiView.delegate !== context.coordinator {
            uiView.delegate = context.coordinator
        }

        // keep return key in sync
        let desiredReturn: UIReturnKeyType = allowNewLines ? .default : .done
        if uiView.returnKeyType != desiredReturn {
            uiView.returnKeyType = desiredReturn
        }

        // toolbar updates
        context.coordinator.applyToolbarIfNeeded(title: toolbarButtonTitle, to: uiView)

        // enforce max length if needed (external changes)
        if text.count > maxLength {
            let truncated = String(text.prefix(maxLength))
            if truncated != text {
                DispatchQueue.main.async { self.text = truncated }
            }
            if !context.coordinator.isEditing {
                context.coordinator.isUpdating = true
                uiView.text = truncated
                context.coordinator.formatText(in: uiView)
                context.coordinator.updateHeight(for: uiView)
                context.coordinator.isUpdating = false
            }
        }

        // external text sync (don’t fight user while editing)
        if !context.coordinator.isEditing {
            let showingPlaceholder = (uiView.textColor == Colors.whiteSecondary.uiColor)

            if text.isEmpty {
                if !showingPlaceholder || uiView.text != placeholder {
                    context.coordinator.isUpdating = true
                    uiView.text = placeholder
                    uiView.textColor = Colors.whiteSecondary.uiColor
                    hashtags.removeAll()
                    context.coordinator.updateHeight(for: uiView)
                    context.coordinator.isUpdating = false
                }
            } else {
                if uiView.text != text || showingPlaceholder {
                    context.coordinator.isUpdating = true
                    uiView.textColor = Colors.whitePrimary.uiColor
                    uiView.text = text
                    context.coordinator.formatText(in: uiView)
                    context.coordinator.updateHeight(for: uiView)
                    context.coordinator.isUpdating = false
                }
            }
        }

        // focus sync (robust)
        context.coordinator.syncFocus(uiView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public final class Coordinator: NSObject, UITextViewDelegate {
        var parent: BorderedTextView

        var isEditing = false
        var isUpdating = false

        private var lastText: String = ""
        private var lastHeight: CGFloat = 0

        // Toolbar
        private var currentToolbarTitle: String?

        // Focus tracking
        private var lastFocusState: Value?
        private var focusToken = UUID()

        init(_ parent: BorderedTextView) {
            self.parent = parent
            self.lastText = parent.text
            self.lastFocusState = parent.focusState
        }

        // MARK: - Toolbar

        func applyToolbarIfNeeded(title: String?, to textView: UITextView) {
            guard currentToolbarTitle != title else { return }
            currentToolbarTitle = title

            if let title {
                let toolbar = UIToolbar()
                toolbar.sizeToFit()

                let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let btn = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(toolbarButtonTapped))
                btn.tintColor = .white
                btn.setTitleTextAttributes([
                    .font: UIFont.custom(.bodyRegular),
                    .foregroundColor: Colors.whitePrimary.uiColor
                ], for: .normal)
                btn.setTitleTextAttributes([
                    .font: UIFont.custom(.bodyRegular),
                    .foregroundColor: Colors.whitePrimary.uiColor
                ], for: .highlighted)

                toolbar.items = [flex, btn]
                textView.inputAccessoryView = toolbar
            } else {
                textView.inputAccessoryView = nil
            }

            if textView.isFirstResponder {
                textView.reloadInputViews()
            }
        }

        @objc private func toolbarButtonTapped() {
            DispatchQueue.main.async {
                self.parent.focusState = nil
                self.parent.onToolbarButtonTap?()
            }
        }

        // MARK: - Focus logic

        func syncFocus(_ textView: UITextView) {
            guard let focusEquals = parent.focusEquals else {
                lastFocusState = parent.focusState
                return
            }

            let current = parent.focusState
            let previous = lastFocusState
            defer { lastFocusState = current }

            // Should be focused -> request focus (bounded retry)
            if current == focusEquals {
                if !textView.isFirstResponder {
                    requestFocus(textView, focusEquals: focusEquals)
                }
                return
            }

            // Should NOT be focused
            cancelFocus()

            guard textView.isFirstResponder else { return }

            if current == nil {
                // Only resign if we were previously focused -> intentional dismiss.
                if previous == focusEquals {
                    DispatchQueue.main.async { textView.resignFirstResponder() }
                } else {
                    // transient state: user tapped into view, let didBeginEditing set focusState
                }
            } else {
                // Another field should be focused
                DispatchQueue.main.async { textView.resignFirstResponder() }
            }
        }

        private func cancelFocus() {
            focusToken = UUID()
        }

        private func requestFocus(_ textView: UITextView, focusEquals: Value) {
            let token = UUID()
            focusToken = token

            func attempt(_ remaining: Int) {
                guard self.focusToken == token else { return }
                guard self.parent.focusState == focusEquals else { return }
                guard textView.window != nil else {
                    if remaining > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { attempt(remaining - 1) }
                    }
                    return
                }

                if textView.isFirstResponder { return }

                if textView.becomeFirstResponder() {
                    return
                }

                if remaining > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { attempt(remaining - 1) }
                }
            }

            DispatchQueue.main.async {
                attempt(10) // ~100ms worst case
            }
        }

        // MARK: - UITextViewDelegate

        public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            true
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true

            // placeholder -> clear
            if textView.textColor == Colors.whiteSecondary.uiColor {
                isUpdating = true
                textView.text = ""
                textView.textColor = Colors.whitePrimary.uiColor
                isUpdating = false
            }

            // set focusState to self if needed
            if let focusEquals = parent.focusEquals, parent.focusState != focusEquals {
                DispatchQueue.main.async { self.parent.focusState = focusEquals }
            }
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false

            // Restore placeholder if empty
            if textView.text.isEmpty {
                isUpdating = true
                textView.text = parent.placeholder
                textView.textColor = Colors.whiteSecondary.uiColor
                isUpdating = false

                DispatchQueue.main.async { self.parent.text = "" }
            }

            // Clear focus only if this view is still marked as focused
            if let focusEquals = parent.focusEquals {
                DispatchQueue.main.async {
                    if self.parent.focusState == focusEquals {
                        self.parent.focusState = nil
                    }
                }
            }
        }

        public func textViewDidChange(_ textView: UITextView) {
            guard !isUpdating else { return }
            guard textView.markedTextRange == nil else { return }

            isEditing = true

            // Enforce max length
            if textView.text.count > parent.maxLength {
                isUpdating = true
                textView.text = String(textView.text.prefix(parent.maxLength))
                isUpdating = false
            }

            // Only update if changed
            let newText = textView.text ?? ""
            if newText != lastText {
                lastText = newText
                DispatchQueue.main.async { self.parent.text = newText }

                formatText(in: textView)
            }

            updateHeight(for: textView)
        }

        public func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText replacement: String
        ) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }

            // Prevent new lines if not allowed (Done behavior)
            if !parent.allowNewLines && replacement == "\n" {
                textView.resignFirstResponder()
                DispatchQueue.main.async { self.parent.focusState = nil }
                return false
            }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: replacement)
            return updatedText.count <= parent.maxLength
        }

        // MARK: - Helper Methods

        func formatText(in textView: UITextView) {
            // Don’t format placeholder
            guard textView.textColor != Colors.whiteSecondary.uiColor else {
                DispatchQueue.main.async { self.parent.hashtags.removeAll() }
                return
            }

            let currentText = textView.text ?? ""
            guard !currentText.isEmpty else {
                DispatchQueue.main.async { self.parent.hashtags.removeAll() }
                return
            }

            let selectedRange = textView.selectedRange
            let attributedString = NSMutableAttributedString(string: currentText)
            let wholeRange = NSRange(location: 0, length: attributedString.length)

            attributedString.addAttributes([
                .font: UIFont.customFont(weight: .regular, style: .footnote),
                .foregroundColor: Colors.whitePrimary.uiColor
            ], range: wholeRange)

            // Compute hashtags locally first, then assign once
            var foundHashtags: [String] = []

            let hashtagPattern = "#[\\p{L}\\p{N}_]{2,53}"
            if let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern) {
                let matches = hashtagRegex.matches(in: currentText, range: wholeRange)
                for match in matches {
                    let hashtagWithSymbol = attributedString.attributedSubstring(from: match.range).string
                    let hashtag = String(hashtagWithSymbol.dropFirst())
                    foundHashtags.append(hashtag)
                    attributedString.addAttributes([
                        .foregroundColor: Colors.hashtag.uiColor
                    ], range: match.range)
                }
            }

            // URLs
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

            isUpdating = true
            textView.attributedText = attributedString
            textView.selectedRange = selectedRange
            isUpdating = false

            DispatchQueue.main.async {
                self.parent.hashtags = foundHashtags
            }
        }

        func updateHeight(for textView: UITextView) {
            let fixedWidth = textView.frame.width
            guard fixedWidth > 0 else { return }

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
