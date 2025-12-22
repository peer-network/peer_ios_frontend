//
//  TransferMessageView.swift
//  Wallet
//
//  Created by Artem Vasin on 17.12.25.
//

import SwiftUI
import DesignSystem

struct TransferMessageView<Value: Hashable>: View {
    @Binding var focusState: Value?
    let focusEquals: Value?

    let onSubmit: (() -> Void)?

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                IconsNew.bubbleLines
                    .iconSize(height: 15)
                    .foregroundStyle(Colors.whitePrimary)

                Text("Add a message (optional)")
                    .appFont(.bodyRegular)
                    .foregroundStyle(Colors.whitePrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            BorderedTextFieldCharsCount(
                backgroundColor: Colors.blackDark,
                text: $text,
                hashtags: .constant([]),
                minHeight: 90,
                placeholder: "e.g., Thanks for the coffee! ☕",
                maxLength: 500,
                allowNewLines: false,
                focusState: $focusState,
                focusEquals: focusEquals,
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
