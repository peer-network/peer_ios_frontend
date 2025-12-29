//
//  RecipientPickerView.swift
//  Wallet
//
//  Created by Artem Vasin on 03.12.25.
//

import SwiftUI
import DesignSystem

struct RecipientPickerView: View {
    @State var text: String = ""

    private enum FocusField: Hashable {
        case recipient
    }

    @FocusState private var focusedField: FocusField?

    var body: some View {
        DataInputTextField(
            trailingIcon: Icons.magnifyingglass,
            text: $text,
            placeholder: "Search user...",
            maxLength: 100,
            focusState: $focusedField,
            focusEquals: .recipient,
            returnKeyType: .search,
            toolbarButtonTitle: "Done",
            onToolbarButtonTap: {
                focusedField = nil
            }
        )
        .padding(20)
    }
}
