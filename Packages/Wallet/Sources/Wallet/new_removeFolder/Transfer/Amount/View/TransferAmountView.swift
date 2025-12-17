//
//  TransferAmountView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import DesignSystem

struct TransferAmountView<Value: Hashable>: View {
    @FocusState.Binding var focusState: Value?
    let focusEquals: Value?

    let onSubmit: (() -> Void)?

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("Enter amount")
                .appFont(.bodyRegular)
                .foregroundStyle(Colors.whitePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            DataInputTextField(
                trailingIcon: Icons.logoCircleWhite,
                text: $text,
                placeholder: "min: 0.00000001",
                maxLength: 100,
                focusState: $focusState,
                focusEquals: focusEquals,
                returnKeyType: .done,
                toolbarButtonTitle: "Done",
                onToolbarButtonTap: {
                    focusState = nil
                }
            )
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}
