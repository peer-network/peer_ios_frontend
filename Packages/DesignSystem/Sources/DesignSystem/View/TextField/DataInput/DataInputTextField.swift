//
//  DataInputTextField.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct DataInputTextField<Value: Hashable>: View {
    let leadingIcon: Image?
    let trailingIcon: Image?
    @Binding var text: String
    let placeholder: String
    let maxLength: Int
    let isSecure: Bool
    let isEditable: Bool

    @FocusState.Binding var focusState: Value?
    let focusEquals: Value?

    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let autocorrectionDisabled: Bool
    let autocapitalization: UITextAutocapitalizationType
    let returnKeyType: UIReturnKeyType

    let onSubmit: (() -> Void)?

    let toolbarButtonTitle: String?
    let onToolbarButtonTap: (() -> Void)?

    @State private var showPassword: Bool = false

    public init(
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        isSecure: Bool = false,
        isEditable: Bool = true,
        focusState: FocusState<Value?>.Binding,
        focusEquals: Value?,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocorrectionDisabled: Bool = false,
        autocapitalization: UITextAutocapitalizationType = .sentences,
        returnKeyType: UIReturnKeyType = .default,
        onSubmit: (() -> Void)? = nil,
        toolbarButtonTitle: String? = nil,
        onToolbarButtonTap: (() -> Void)? = nil
    ) {
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self._text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.isSecure = isSecure
        self.isEditable = isEditable
        self._focusState = focusState
        self.focusEquals = focusEquals
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocorrectionDisabled = autocorrectionDisabled
        self.autocapitalization = autocapitalization
        self.returnKeyType = returnKeyType
        self.onSubmit = onSubmit
        self.toolbarButtonTitle = toolbarButtonTitle
        self.onToolbarButtonTap = onToolbarButtonTap
    }

    public var body: some View {
        HStack(spacing: 10) {
            if let leadingIcon {
                leadingIcon
                    .iconSize(width: 24, height: 24)
                    .foregroundStyle(Colors.hashtag)
            }

            DataInputTextFieldRepresentable(
                text: $text,
                placeholder: placeholder,
                maxLength: maxLength,
                isSecure: isSecure && !showPassword,
                isEditable: isEditable,
                focusState: $focusState,
                focusEquals: focusEquals,
                keyboardType: keyboardType,
                textContentType: textContentType,
                autocorrectionDisabled: autocorrectionDisabled,
                autocapitalization: autocapitalization,
                returnKeyType: returnKeyType,
                onSubmit: onSubmit,
                toolbarButtonTitle: toolbarButtonTitle,
                onToolbarButtonTap: onToolbarButtonTap
            )
            .focused($focusState, equals: isEditable ? focusEquals : nil)

            if isSecure && !text.isEmpty {
                Button {
                    withAnimation(nil) { showPassword.toggle() }
                } label: {
                    Group {
                        if showPassword {
                            IconsNew.eyeWithSlash
                                .iconSize(width: 24, height: 24)
                        } else {
                            IconsNew.eye
                                .iconSize(width: 24, height: 24)
                        }
                    }
                    .foregroundStyle(Colors.greyIcons)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showPassword ? "Hide password" : "Show password")
            } else if let trailingIcon {
                trailingIcon
                    .iconSize(width: 24, height: 24)
                    .foregroundStyle(Colors.whitePrimary)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .background { Colors.inactiveDark }
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        .contentShape(.rect)
        .onTapGesture {
            if isEditable { focusState = focusEquals }
        }
    }
}
