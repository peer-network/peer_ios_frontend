//
//  DataInputTextField.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct DataInputTextField<Value: Hashable>: View {
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

    public var body: some View {
        HStack(spacing: 0) {
            DataInputTextFieldRepresentable(
                text: $text,
                placeholder: placeholder,
                maxLength: maxLength,
                focusState: $focusState,
                focusEquals: focusEquals
            )
            .focused($focusState, equals: focusEquals)
            .frame(height: 50)
        }
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
            focusState = focusEquals
        }
    }
}
