//
//  DataInputTextFieldRepresentable.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct DataInputTextFieldRepresentable<Value: Hashable>: UIViewRepresentable {
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

    public init(
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        isSecure: Bool,
        isEditable: Bool,
        focusState: FocusState<Value?>.Binding,
        focusEquals: Value?,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocorrectionDisabled: Bool = false,
        autocapitalization: UITextAutocapitalizationType = .sentences,
        returnKeyType: UIReturnKeyType = .default,
        onSubmit: (() -> Void)? = nil
    ) {
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

    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        textField.font = UIFont.custom(.bodyRegular)
        textField.textColor = Colors.textActive.uiColor
        textField.tintColor = Colors.hashtag.uiColor
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Colors.textSuggestions.uiColor]
        )

        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.autocorrectionType = autocorrectionDisabled ? .no : .yes
        textField.autocapitalizationType = autocapitalization
        textField.returnKeyType = returnKeyType

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textField.text = text

        textField.isSecureTextEntry = isSecure

        if isEditable {
            textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        } else {
            textField.isUserInteractionEnabled = false
        }

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            context.coordinator.isUpdating = true
            uiView.text = text
            context.coordinator.isUpdating = false
        }

        if uiView.isSecureTextEntry != isSecure {
            let wasFirstResponder = uiView.isFirstResponder
            let currentText = uiView.text

            context.coordinator.isUpdating = true
            uiView.isSecureTextEntry = isSecure

            // iOS caret/blank text workaround when toggling secure while active
            if wasFirstResponder {
                // Re-assign text to keep it visible, and restore caret
                uiView.text = nil
                uiView.text = currentText
                uiView.selectedTextRange = uiView.textRange(from: uiView.endOfDocument, to: uiView.endOfDocument)

                // Calm the keyboard relayout to reduce constraint spew
                UIView.performWithoutAnimation {
                    uiView.reloadInputViews()
                }
            }
            context.coordinator.isUpdating = false
        }

        if uiView.isUserInteractionEnabled == isEditable {
            if !isEditable {
                uiView.resignFirstResponder()
            }
        }
        uiView.isUserInteractionEnabled = isEditable
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DataInputTextFieldRepresentable
        var isUpdating = false

        init(_ textField: DataInputTextFieldRepresentable) {
            self.parent = textField
        }

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            guard parent.isEditable else { return false }
            return true
        }

        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard parent.isEditable else { return false }
            // Handle max length
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= parent.maxLength
        }

        @objc func textDidChange(_ sender: UITextField) {
            guard parent.isEditable, !isUpdating else { return }
            let newText = sender.text ?? ""
            if parent.text != newText {
                DispatchQueue.main.async {
                    self.parent.text = newText
                }
            }
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            parent.onSubmit?()
            return true
        }
    }
}
