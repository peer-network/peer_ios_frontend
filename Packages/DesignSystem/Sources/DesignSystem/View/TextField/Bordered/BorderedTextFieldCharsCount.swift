//
//  BorderedTextFieldCharsCount.swift
//  DesignSystem
//
//  Created by Artem Vasin on 27.05.25.
//

import SwiftUI

public struct BorderedTextFieldCharsCount<Value: Hashable>: View {
    let backgroundColor: Color
    
    @Binding var text: String
    @Binding var hashtags: [String]

    @State private var dynamicHeight: CGFloat

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
        backgroundColor: Color = Colors.inactiveDark,
        text: Binding<String>,
        hashtags: Binding<[String]>,
        minHeight: CGFloat,
        placeholder: String,
        maxLength: Int,
        allowNewLines: Bool,
        focusState: Binding<Value?>,
        focusEquals: Value?,
        toolbarButtonTitle: String? = nil,
        onToolbarButtonTap: (() -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self._text = text
        self._hashtags = hashtags
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.minHeight = minHeight
        self.allowNewLines = allowNewLines

        self._focusState = focusState
        self.focusEquals = focusEquals

        self.toolbarButtonTitle = toolbarButtonTitle
        self.onToolbarButtonTap = onToolbarButtonTap

        self._dynamicHeight = State(initialValue: minHeight)
    }

    // MARK: - Compatibility initializer (keeps old call sites compiling)
    public init(
        backgroundColor: Color = Colors.inactiveDark,
        text: Binding<String>,
        hashtags: Binding<[String]>,
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
            backgroundColor: backgroundColor,
            text: text,
            hashtags: hashtags,
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

    public var body: some View {
        VStack(spacing: 5) {
            BorderedTextView(
                text: $text,
                hashtags: $hashtags,
                height: $dynamicHeight,
                minHeight: minHeight,
                placeholder: placeholder,
                maxLength: maxLength,
                allowNewLines: allowNewLines,
                focusState: $focusState,
                focusEquals: focusEquals,
                toolbarButtonTitle: toolbarButtonTitle,
                onToolbarButtonTap: onToolbarButtonTap
            )
            .frame(height: dynamicHeight)

            Text("\(text.count)/\(maxLength)")
                .fontDesign(.monospaced)
                .font(.customFont(weight: .regular, style: .footnote))
                .foregroundStyle(Colors.whiteSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(backgroundColor)
        )
        .contentShape(.rect)
        .onTapGesture {
            focusState = focusEquals
        }
    }
}
