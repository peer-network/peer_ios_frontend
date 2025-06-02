//
//  BorderedTextFieldCharsCount.swift
//  DesignSystem
//
//  Created by Artem Vasin on 27.05.25.
//

import SwiftUI

public struct BorderedTextFieldCharsCount<Value: Hashable>: View {
    @Binding var text: String
    @Binding var hashtags: [String]

    @State private var dynamicHeight: CGFloat

    let placeholder: String
    let maxLength: Int
    let minHeight: CGFloat
    let allowNewLines: Bool

    @FocusState.Binding var focusState: Value?
    let focusEquals: Value?

    public init(
        text: Binding<String>,
        hashtags: Binding<[String]>,
        minHeight: CGFloat,
        placeholder: String,
        maxLength: Int,
        allowNewLines: Bool,
        focusState: FocusState<Value?>.Binding,
        focusEquals: Value?
    ) {
        self._text = text
        self._hashtags = hashtags
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.minHeight = minHeight
        self.allowNewLines = allowNewLines
        self._focusState = focusState
        self.focusEquals = focusEquals
        self.dynamicHeight = minHeight
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
                focusEquals: focusEquals
            )
            .focused($focusState, equals: focusEquals)
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
                .foregroundStyle(Colors.inactiveDark)
        )
        .contentShape(.rect)
        .onTapGesture {
            focusState = focusEquals
        }
    }
}
