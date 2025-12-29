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

    // Plain Binding (drive focus ourselves)
    @Binding var focusState: Value?
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
        focusState: Binding<Value?>,
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
        let tf = UITextField()
        tf.delegate = context.coordinator

        tf.font = UIFont.custom(.bodyRegular)
        tf.textColor = Colors.whitePrimary.uiColor
        tf.tintColor = Colors.hashtag.uiColor
        tf.backgroundColor = .clear
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Colors.whiteSecondary.uiColor]
        )

        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // initial state
        tf.text = text
        tf.isSecureTextEntry = isSecure
        tf.isUserInteractionEnabled = isEditable

        // wiring (once per UITextField instance)
        context.coordinator.installTargetsIfNeeded(on: tf)
        context.coordinator.installPrimaryActionIfNeeded(on: tf)
        context.coordinator.applyToolbarIfNeeded(title: toolbarButtonTitle, to: tf)

        // initial keyboard config
        tf.keyboardType = keyboardType
        tf.textContentType = textContentType
        tf.autocorrectionType = autocorrectionDisabled ? .no : .yes
        tf.autocapitalizationType = autocapitalization
        tf.returnKeyType = returnKeyType

        return tf
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        // keep freshest bindings/closures
        context.coordinator.parent = self

        // keep delegate connected
        if uiView.delegate !== context.coordinator {
            uiView.delegate = context.coordinator
        }

        // update editability
        if uiView.isUserInteractionEnabled != isEditable {
            uiView.isUserInteractionEnabled = isEditable
            if !isEditable, uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }

        // keep keyboard config in sync (only when changed)
        if uiView.keyboardType != keyboardType { uiView.keyboardType = keyboardType }
        if uiView.textContentType != textContentType { uiView.textContentType = textContentType }
        let desiredAuto: UITextAutocorrectionType = autocorrectionDisabled ? .no : .yes
        if uiView.autocorrectionType != desiredAuto { uiView.autocorrectionType = desiredAuto }
        if uiView.autocapitalizationType != autocapitalization { uiView.autocapitalizationType = autocapitalization }
        if uiView.returnKeyType != returnKeyType { uiView.returnKeyType = returnKeyType }

        // ensure targets exist (safe if already installed)
        context.coordinator.installTargetsIfNeeded(on: uiView)
        context.coordinator.installPrimaryActionIfNeeded(on: uiView)

        // text sync
        if uiView.text != text {
            context.coordinator.isUpdating = true
            uiView.text = text
            context.coordinator.isUpdating = false
        }

        // secure sync + caret workaround
        if uiView.isSecureTextEntry != isSecure {
            let wasFirstResponder = uiView.isFirstResponder
            let currentText = uiView.text

            context.coordinator.isUpdating = true
            uiView.isSecureTextEntry = isSecure

            if wasFirstResponder {
                uiView.text = nil
                uiView.text = currentText
                uiView.selectedTextRange = uiView.textRange(from: uiView.endOfDocument, to: uiView.endOfDocument)
                UIView.performWithoutAnimation { uiView.reloadInputViews() }
            }
            context.coordinator.isUpdating = false
        }

        context.coordinator.applyToolbarIfNeeded(title: toolbarButtonTitle, to: uiView)

        // focus sync
        context.coordinator.syncFocus(uiView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DataInputTextFieldRepresentable
        var isUpdating = false

        private var currentToolbarTitle: String?
        private var targetsInstalled = false

        // Focus state tracking to prevent “tap then blur” and to detect intentional clears
        private var lastFocusState: Value?

        // Prevent clearing focus during Return(.next) handoff
        private var isTransferringFocus = false

        // Bounded retry token for becomeFirstResponder race
        private var focusToken = UUID()

        // Primary action install id (so we don’t stack actions)
        @available(iOS 14.0, *)
        private var primaryActionID: UIAction.Identifier?

        init(_ parent: DataInputTextFieldRepresentable) {
            self.parent = parent
        }

        // MARK: Targets / actions

        func installTargetsIfNeeded(on textField: UITextField) {
            // We can install once per UITextField instance.
            // If editability changes, we don’t need to uninstall; we gate by isEditable in handlers.
            guard !targetsInstalled else { return }
            targetsInstalled = true

            textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(didEndOnExit(_:)), for: .editingDidEndOnExit)
        }

        func installPrimaryActionIfNeeded(on textField: UITextField) {
            guard #available(iOS 14.0, *) else { return }

            // Install once per instance; if updateUIView gets called with same UITextField,
            // we should not add duplicate UIActions.
            if primaryActionID != nil { return }

            let action = UIAction { [weak self] action in
                guard let self else { return }
                guard let tf = action.sender as? UITextField else { return }
                self.handleReturn(from: tf)
            }
            primaryActionID = action.identifier
            textField.addAction(action, for: .primaryActionTriggered)
        }

        // MARK: Toolbar

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

        @objc private func toolbarButtonTapped() {
            DispatchQueue.main.async {
                self.parent.focusState = nil
                self.parent.onToolbarButtonTap?()
            }
        }

        // MARK: Focus logic

        func syncFocus(_ textField: UITextField) {
            guard parent.isEditable else {
                cancelFocus()
                if textField.isFirstResponder { textField.resignFirstResponder() }
                lastFocusState = parent.focusState
                return
            }

            guard let focusEquals = parent.focusEquals else {
                lastFocusState = parent.focusState
                return
            }

            let current = parent.focusState
            let previous = lastFocusState
            defer { lastFocusState = current }

            // Should be focused -> request focus (with bounded retry if needed)
            if current == focusEquals {
                if !textField.isFirstResponder {
                    requestFocus(textField, focusEquals: focusEquals)
                }
                return
            }

            // Should NOT be focused:
            cancelFocus()

            // If UITextField is focused but binding is not:
            guard textField.isFirstResponder else { return }

            if current == nil {
                // If we were focused and focus became nil -> intentional dismiss -> resign.
                // If we were not focused and current is nil -> transient (tap) -> don't resign here.
                if previous == focusEquals {
                    DispatchQueue.main.async { textField.resignFirstResponder() }
                } else {
                    // transient state: let didBeginEditing set focusState, don't fight UIKit
                }
            } else {
                // Another field should be focused
                DispatchQueue.main.async { textField.resignFirstResponder() }
            }
        }

        private func cancelFocus() {
            focusToken = UUID()
        }

        private func requestFocus(_ textField: UITextField, focusEquals: Value) {
            let token = UUID()
            focusToken = token

            // Small bounded retry: enough to survive responder handoff on `.next`,
            // but not so much it becomes “busy”.
            func attempt(_ remaining: Int) {
                guard self.focusToken == token else { return }
                guard self.parent.isEditable else { return }
                guard self.parent.focusState == focusEquals else { return }
                guard textField.window != nil else {
                    if remaining > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { attempt(remaining - 1) }
                    }
                    return
                }

                if textField.isFirstResponder { return }

                if textField.becomeFirstResponder() {
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

        // MARK: UITextFieldDelegate

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.isEditable
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            guard parent.isEditable, let focusEquals = parent.focusEquals else { return }
            if parent.focusState != focusEquals {
                DispatchQueue.main.async { self.parent.focusState = focusEquals }
            }
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            guard let focusEquals = parent.focusEquals else { return }
            if isTransferringFocus { return }

            // Clear only if this field is still marked focused.
            DispatchQueue.main.async {
                if self.parent.focusState == focusEquals {
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

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            handleReturn(from: textField)
            return false
        }

        // MARK: Events

        @objc private func textDidChange(_ sender: UITextField) {
            guard parent.isEditable, !isUpdating else { return }
            let newText = sender.text ?? ""
            if parent.text != newText {
                DispatchQueue.main.async { self.parent.text = newText }
            }
        }

        @objc private func didEndOnExit(_ sender: UITextField) {
            handleReturn(from: sender)
        }

        private func handleReturn(from textField: UITextField) {
            guard parent.isEditable else { return }

            switch parent.returnKeyType {
            case .next:
                // prevent end-editing from clearing focus while we transfer to next
                isTransferringFocus = true

                // user sets parent.focusState to next (e.g., .password)
                parent.onSubmit?()

                // release current responder after state change has been queued
                DispatchQueue.main.async {
                    textField.resignFirstResponder()

                    // allow end editing to clear focus again later
                    DispatchQueue.main.async {
                        self.isTransferringFocus = false
                    }
                }

            default:
                textField.resignFirstResponder()
                parent.onSubmit?()
            }
        }
    }
}
