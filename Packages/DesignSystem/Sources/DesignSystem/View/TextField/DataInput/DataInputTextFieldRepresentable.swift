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

    let toolbarButtonTitle: String?
    let onToolbarButtonTap: (() -> Void)?

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
        onSubmit: (() -> Void)? = nil,
        toolbarButtonTitle: String? = nil,
        onToolbarButtonTap: (() -> Void)? = nil
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
        self.toolbarButtonTitle = toolbarButtonTitle
        self.onToolbarButtonTap = onToolbarButtonTap
    }

    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        context.coordinator.textField = textField

        textField.font = UIFont.custom(.bodyRegular)
        textField.textColor = Colors.whitePrimary.uiColor
        textField.tintColor = Colors.hashtag.uiColor
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Colors.whiteSecondary.uiColor]
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
            textField.addTarget(context.coordinator,
                                action: #selector(Coordinator.textDidChange(_:)),
                                for: .editingChanged)
        } else {
            textField.isUserInteractionEnabled = false
        }

        context.coordinator.applyToolbarIfNeeded(title: toolbarButtonTitle, to: textField)

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        // keep coordinator in sync with latest struct values
        context.coordinator.parent = self

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
                uiView.text = nil
                uiView.text = currentText
                uiView.selectedTextRange = uiView.textRange(from: uiView.endOfDocument, to: uiView.endOfDocument)

                UIView.performWithoutAnimation {
                    uiView.reloadInputViews()
                }
            }
            context.coordinator.isUpdating = false
        }

        // editable changes
        if uiView.isUserInteractionEnabled != isEditable {
            uiView.isUserInteractionEnabled = isEditable
            if !isEditable { uiView.resignFirstResponder() }
        }

        context.coordinator.applyToolbarIfNeeded(title: toolbarButtonTitle, to: uiView)

        let shouldBeFirstResponder = (focusState == focusEquals) && isEditable
        if shouldBeFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !shouldBeFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DataInputTextFieldRepresentable
        var isUpdating = false

        weak var textField: UITextField?
        private var currentToolbarTitle: String?

        init(_ parent: DataInputTextFieldRepresentable) {
            self.parent = parent
        }

        func applyToolbarIfNeeded(title: String?, to textField: UITextField) {
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
                textField.inputAccessoryView = toolbar
            } else {
                textField.inputAccessoryView = nil
            }

            if textField.isFirstResponder {
                textField.reloadInputViews()
            }
        }

        @objc func toolbarButtonTapped() {
            textField?.resignFirstResponder()

            DispatchQueue.main.async {
                self.parent.focusState = nil
                self.parent.onToolbarButtonTap?()
            }
        }

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.isEditable
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.focusState = self.parent.focusEquals
            }
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                if self.parent.focusState == self.parent.focusEquals {
                    self.parent.focusState = nil
                }
            }
        }

        public func textField(_ textField: UITextField,
                              shouldChangeCharactersIn range: NSRange,
                              replacementString string: String) -> Bool {
            guard parent.isEditable else { return false }

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
