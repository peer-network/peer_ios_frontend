//
//  DataInputTextField.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct DataInputTextField<Value: Hashable>: View {
    let leadingIcon: Image?
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

    @State private var showPassword: Bool = false

    public init(
        leadingIcon: Image? = nil,
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
        onSubmit: (() -> Void)? = nil
    ) {
        self.leadingIcon = leadingIcon
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
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let leadingIcon {
                leadingIcon
                    .iconSize(width: 20, height: 20)
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
                onSubmit: onSubmit
            )
            .focused($focusState, equals: isEditable ? focusEquals : nil)

            if isSecure && !text.isEmpty {
                Button {
                    withAnimation(nil) {
                        showPassword.toggle()
                    }
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
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .background {
            Colors.whitePrimary
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1)
        }
        .contentShape(.rect)
        .onTapGesture {
            if isEditable {
                focusState = focusEquals
            }
        }
    }
}
