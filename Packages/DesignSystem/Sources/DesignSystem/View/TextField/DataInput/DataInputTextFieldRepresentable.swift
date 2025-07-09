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

    @FocusState.Binding var focusState: Value?
    let focusEquals: Value?

    public init(
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        focusState: FocusState<Value?>.Binding,
        focusEquals: Value?
    ) {
        self._text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self._focusState = focusState
        self.focusEquals = focusEquals
    }

    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        textField.backgroundColor = .clear

        textField.text = text
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Colors.textSuggestions.uiColor]
        )
        textField.font = UIFont.custom(.bodyRegular)
        textField.textColor = Colors.textActive.uiColor
        textField.tintColor = Colors.hashtag.uiColor

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DataInputTextFieldRepresentable

        init(_ textField: DataInputTextFieldRepresentable) {
            self.parent = textField
        }

        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Handle max length
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= parent.maxLength
        }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Dismiss keyboard when return is pressed
            textField.resignFirstResponder()
            return true
        }
    }
}
